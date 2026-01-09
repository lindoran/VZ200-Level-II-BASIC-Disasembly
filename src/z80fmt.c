/* 
    This is a z80dasm formatter, its kind of crap but it works
    It reads z80dasm output and reformats it into a cleaner listing,
    with optional symbol replacement and label columns.

    why i don't just use ghedra or something fancier? because this is a
    simple standalone tool that can be easily integrated into existing
    workflows without heavy dependencies.

    this will just dump to stdout, so you can redirect it to a file as needed.
    2024-06-04  v1.0  Initial version
    2024-06-10  v1.1  Added label column support and improved symbol replacement

    License: Public Domain
    disclaimer: use at your own risk, no warranty expressed or implied.
    copyright 2024 by D. Collins (really - honestly mostly ai generated)

    Usage:
      z80fmt <input.asm>
      z80fmt <symbols.txt> <input.asm>
      cat input.asm | z80fmt
*/


#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>

#define MAX_LINE    1024
#define MAX_SYMBOLS 4096
#define MAX_NAME    64

typedef struct {
    char addr[5];   /* 4 hex chars + NUL */
    char name[MAX_NAME];
} Symbol;

static Symbol symbols[MAX_SYMBOLS];
static int symbol_count = 0;

/* ---------------- Utility helpers ---------------- */

static void rstrip(char *s) {
    size_t len = strlen(s);
    while (len > 0 && (s[len-1] == '\n' || s[len-1] == '\r' ||
                       s[len-1] == ' '  || s[len-1] == '\t'))
        s[--len] = '\0';
}

static char *lstrip(char *s) {
    while (*s == ' ' || *s == '\t')
        s++;
    return s;
}

static void trim(char *s) {
    char *p = lstrip(s);
    if (p != s)
        memmove(s, p, strlen(p) + 1);
    rstrip(s);
}

static void upper_hex(char *s) {
    for (; *s; s++)
        *s = (char)toupper((unsigned char)*s);
}

/* Safe bounded copy */
static void safe_copy(char *dst, size_t dst_size, const char *src) {
    size_t n = strlen(src);
    if (n >= dst_size)
        n = dst_size - 1;
    memcpy(dst, src, n);
    dst[n] = '\0';
}
/* ---------------- Symbol table ---------------- */

static const char *lookup_symbol(const char *addr4) {
    for (int i = 0; i < symbol_count; i++) {
        if (strcmp(symbols[i].addr, addr4) == 0)
            return symbols[i].name;
    }
    return NULL;
}

static void load_symbols(FILE *f) {
    char line[MAX_LINE];

    while (fgets(line, sizeof(line), f)) {
        rstrip(line);
        char *p = lstrip(line);

        if (*p == '\0' || *p == '#')
            continue;

        char *hash = strchr(p, '#');
        if (hash)
            *hash = '\0';

        trim(p);
        if (*p == '\0')
            continue;

        char *colon = strchr(p, ':');
        if (!colon)
            continue;

        *colon = '\0';
        char *name = p;
        char *addr = colon + 1;

        trim(name);
        trim(addr);

        if (strlen(addr) != 4)
            continue;

        if (symbol_count >= MAX_SYMBOLS)
            break;

        safe_copy(symbols[symbol_count].name, MAX_NAME, name);
        safe_copy(symbols[symbol_count].addr, 5, addr);
        upper_hex(symbols[symbol_count].addr);

        symbol_count++;
    }
}

/* ---------------- Label detection ---------------- */

static int is_label_line(const char *line, char *label_out, size_t out_size) {
    const char *p = lstrip((char *)line);
    const char *colon = strchr(p, ':');
    if (!colon)
        return 0;

    const char *q = colon + 1;
    while (*q) {
        if (!isspace((unsigned char)*q))
            return 0;
        q++;
    }

    size_t len = (size_t)(colon - p);
    if (len == 0 || len >= out_size)
        return 0;

    for (size_t i = 0; i < len; i++) {
        char c = p[i];
        if (!(isalnum((unsigned char)c) || c == '_'))
            return 0;
    }

    memcpy(label_out, p, len);
    label_out[len] = '\0';
    return 1;
}

/* ---------------- Parse comment address + bytes ---------------- */

static int parse_comment_addr_bytes(const char *comment,
                                    char addr_out[5],
                                    char *bytes_out,
                                    size_t bytes_size)
{
    const char *p = comment;
    if (*p == ';')
        p++;
    while (*p == ' ' || *p == '\t')
        p++;

    char addr[5];
    for (int i = 0; i < 4; i++) {
        if (!isxdigit((unsigned char)p[i]))
            return 0;
        addr[i] = p[i];
    }
    addr[4] = '\0';
    upper_hex(addr);
    safe_copy(addr_out, 5, addr);

    p += 4;
    while (*p == ' ' || *p == '\t')
        p++;

    char buf[64] = {0};
    size_t buf_len = 0;

    int byte_count = 0;
    while (byte_count < 3 &&
           isxdigit((unsigned char)p[0]) &&
           isxdigit((unsigned char)p[1]))
    {
        if (buf_len + 3 >= sizeof(buf))
            break;

        if (buf_len > 0)
            buf[buf_len++] = ' ';

        buf[buf_len++] = p[0];
        buf[buf_len++] = p[1];

        p += 2;
        while (*p == ' ' || *p == '\t')
            p++;

        byte_count++;
    }

    buf[buf_len] = '\0';
    safe_copy(bytes_out, bytes_size, buf);
    return 1;
}
/* ---------------- Replace label references in operands ---------------- */

static void replace_operand_labels(const char *operand,
                                   char *out,
                                   size_t out_size)
{
    size_t out_len = 0;
    size_t i = 0;
    size_t len = strlen(operand);

    while (i < len && out_len + 1 < out_size) {
        /* Check for hex address patterns: 0XXXXh or just lXXXXh */
        if ((operand[i] == '0' || operand[i] == 'l') && i + 5 < len) {
            char tmp[5];
            int ok = 1;
            int start_offset = (operand[i] == '0') ? 1 : 1;  /* skip '0' or 'l' */
            
            for (int k = 0; k < 4; k++) {
                char c = operand[i + start_offset + k];
                if (!isxdigit((unsigned char)c)) {
                    ok = 0;
                    break;
                }
                tmp[k] = c;
            }
            tmp[4] = '\0';

            if (ok && operand[i + start_offset + 4] == 'h') {
                int pattern_len = start_offset + 5;  /* length of entire pattern */
                int before_ok = (i == 0) ||
                                !isalnum((unsigned char)operand[i - 1]);
                int after_ok  = (i + pattern_len >= len) ||
                                !isalnum((unsigned char)operand[i + pattern_len]);

                if (before_ok && after_ok) {
                    upper_hex(tmp);
                    const char *sym = lookup_symbol(tmp);
                    if (sym) {
                        size_t sl = strlen(sym);
                        if (out_len + sl >= out_size)
                            sl = out_size - 1 - out_len;
                        memcpy(out + out_len, sym, sl);
                        out_len += sl;
                        i += pattern_len;
                        continue;
                    }
                }
            }
        }

        out[out_len++] = operand[i++];
    }

    out[out_len] = '\0';
}

/* ---------------- Main ---------------- */

int main(int argc, char **argv) {
    FILE *symf = NULL;
    FILE *in = NULL;

    /* Help option */
    if (argc == 2 &&
       (strcmp(argv[1], "-h") == 0 || strcmp(argv[1], "--help") == 0)) {

        printf("Usage:\n");
        printf("  z80fmt <input.asm>\n");
        printf("  z80fmt <symbols.txt> <input.asm>\n");
        printf("  cat input.asm | z80fmt\n\n");
        printf("Description:\n");
        printf("  Formats z80dasm output into a clean listing with optional\n");
        printf("  symbol replacement and label columns.\n");
        return 0;
    }

    /* No arguments: check if stdin is a terminal */
    if (argc == 1) {
        if (isatty(STDIN_FILENO)) {
            printf("z80fmt: no input\n");
            printf("Try 'z80fmt --help' for usage.\n");
            return 1;
        } else {
            in = stdin;
        }
    }
    else if (argc == 2) {
        in = fopen(argv[1], "r");
        if (!in) {
            fprintf(stderr, "Error: cannot open %s\n", argv[1]);
            return 1;
        }
    }
    else if (argc == 3) {
        symf = fopen(argv[1], "r");
        if (symf) {
            load_symbols(symf);
            fclose(symf);
        }
        in = fopen(argv[2], "r");
        if (!in) {
            fprintf(stderr, "Error: cannot open %s\n", argv[2]);
            return 1;
        }
    }
    else {
        fprintf(stderr, "z80fmt: too many arguments\n");
        fprintf(stderr, "Try 'z80fmt --help' for usage.\n");
        return 1;
    }

    printf("; ------------------------------------------------------------\n");
    printf("; Listing processed by z80fmt (C version)\n");
    printf("; ------------------------------------------------------------\n\n");
    char line[MAX_LINE];
    char current_label[MAX_NAME] = "";
    int have_current_label = 0;
    int label_printed = 0;

    while (fgets(line, sizeof(line), in)) {
        char original[MAX_LINE];
        safe_copy(original, sizeof(original), line);

        rstrip(line);

        /* Detect raw label lines like: l0001h: and suppress them */
        char label_buf[MAX_NAME];
        if (is_label_line(line, label_buf, sizeof(label_buf))) {
            safe_copy(current_label, sizeof(current_label), label_buf);
            have_current_label = 1;
            label_printed = 0;
            /* DON'T print the label line - just track it */
            continue;
        }

        /* Look for comment with address + bytes */
        char *semi = strchr(line, ';');
        if (!semi) {
            printf("%s\n", original);
            continue;
        }

        char addr[5];
        char bytes[64];
        if (!parse_comment_addr_bytes(semi, addr, bytes, sizeof(bytes))) {
            printf("%s\n", original);
            continue;
        }

        /* Extract instruction part */
        char instr_part[MAX_LINE];
        size_t instr_len = (size_t)(semi - line);
        if (instr_len >= sizeof(instr_part))
            instr_len = sizeof(instr_part) - 1;
        memcpy(instr_part, line, instr_len);
        instr_part[instr_len] = '\0';
        trim(instr_part);

        char mnemonic[MAX_NAME] = "";
        char operand[MAX_LINE] = "";
        char instr_final[MAX_LINE] = "";

        if (instr_part[0] != '\0') {
            char *p = instr_part;
            char *q = p;

            while (*q && !isspace((unsigned char)*q))
                q++;

            size_t mlen = (size_t)(q - p);
            if (mlen >= sizeof(mnemonic))
                mlen = sizeof(mnemonic) - 1;
            memcpy(mnemonic, p, mlen);
            mnemonic[mlen] = '\0';

            while (*q && isspace((unsigned char)*q))
                q++;

            safe_copy(operand, sizeof(operand), q);

            char operand_repl[MAX_LINE];
            replace_operand_labels(operand, operand_repl, sizeof(operand_repl));

            instr_final[0] = '\0';
            safe_copy(instr_final, sizeof(instr_final), mnemonic);

            if (operand_repl[0] != '\0') {
                size_t len = strlen(instr_final);
                if (len + 1 < sizeof(instr_final)) {
                    instr_final[len] = ' ';
                    instr_final[len + 1] = '\0';
                }
                size_t space_left = sizeof(instr_final) - strlen(instr_final);
                if (space_left > 1)
                    safe_copy(instr_final + strlen(instr_final),
                              space_left,
                              operand_repl);
            }
        }

        /* ---------------- Label column logic (FIXED) ---------------- */

        char label_col[32] = "";
        const char *label_to_use = NULL;

        const char *sym_for_addr = lookup_symbol(addr);

        if (sym_for_addr) {
            /* New symbol starts here - always show it */
            label_to_use = sym_for_addr;
            safe_copy(current_label, sizeof(current_label), sym_for_addr);
            have_current_label = 1;
            label_printed = 0;
        } else if (have_current_label && !label_printed) {
            /* First instruction of a local label - show it once */
            label_to_use = current_label;
            label_printed = 1;
        } else {
            /* No label for this line */
            label_to_use = "";
        }

        if (label_to_use[0] != '\0') {
            char tmp[MAX_NAME + 2];
            snprintf(tmp, sizeof(tmp), "%s:", label_to_use);
            safe_copy(label_col, sizeof(label_col), tmp);
        } else {
            label_col[0] = '\0';
        }

        /* Pad label column to fixed width */
        size_t ll = strlen(label_col);
        while (ll < 12) {
            label_col[ll++] = ' ';
        }
        label_col[ll] = '\0';

        /* ---------------- Final formatted output ---------------- */

        printf("%s:  %-11s   %s %s\n",
               addr,
               bytes[0] ? bytes : "",
               label_col,
               instr_final);
    }

    if (in != stdin)
        fclose(in);

    return 0;
}