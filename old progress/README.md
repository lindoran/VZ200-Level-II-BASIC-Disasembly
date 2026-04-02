<H1>A project to document the VZ200 ROM</H1>
<p>
Maybe this gets good enough we can get it to assemble, for now I would just like to be able to understand how the rom works a bit better. We can lean heavy on the existing german disasembly found at <a href=http://www.vz200.org/bushy/manuals/book%20-%20Laser310-ROM-Listing-german.pdf>bushys.</a> I'll also back it up in the /doc folder. You can also find a real crappy formatter for z80dasm output in /src.  Its mostly ai generated code but works. I haven't bothered to teach myself Gehdra, I suppose that is better suited for projects like this.  I like making my own toolchains and its simple enough to work just in vscode which makes my brain happy.
</p>
<p>
If you would like to pick at this and do a pull request please do! I just ask you don't mess with the format that is placed by the tool because I would really like to make a formatter that can pull the asembly out and make a file we can asemble.  This format will make it easy.  Simply put comments after  ;  and do 6 spaces after the numonics / operands, don't mess with the spacing or addressing otherwise.
</p>
<p>
There's a few spots were the translator barfs (I think on what it sees as self modifiying code.)  Those will be easy to pick out in vz200-list.asm.  They will need to be rebuilt from the PDF.  I think mostly these are tables, but will have to see.  I have bult a simple symbols.txt, this was mainly just to get started.  For now the tools don't update this, really they can only build a new vz200-list.asm.  If you work out a new symbol simply start a new document the format is SYMBOLANME : 4 DIGIT HEX.  We can pull that into the toolchain when I get a chance to update the code to update the symbols from a list. keep in mind a symbol can be max 10 characters and should be a unique, legal symbol name.
</p>
<p>
Obviously this is Level II basic which is a variant of BASIC80 at it's core.  While that specific code for the 6502 and 8086 and presumibly through the dragon restoration project the 6809 has been mostly opened by Microsoft, its unclear the status of the Z80 branch. This is all obviously educational, please keep in mind that the ROMS themselves are Licenced by Video Technologies (nee VTECH), and that the Licencor is Microsoft (presumibly).  The copywrite on the ROM code is Microsoft.
</p>
<H3>The Files:</H3>
<p>
<ul>
    <li>symbols.txt - This is the symbol file used by the preformatter</li>
    <li>newsym.txt - if I add a symbol ill put it here... i need to work a better way through this</li>
    <li>vz200-list.asm - this is the z80dsam output, formatted by the tool in /src this is the file we are annotaing</li>
    <li>/src - contains z80fmt source </li>
    <li>/doc - some pdf's that might help</li>
</ul>