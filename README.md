<H1>A project to document the VZ200 ROM</H1>
<p>
Maybe this gets good enough we can get it to assemble, for now I would just like to be able to understand how the rom works a bit better. We can lean heavy on the existing german translation found at <a href=http://www.vz200.org/bushy/manuals/book%20-%20Laser310-ROM-Listing-german.pdf>bushys.</a> I'll also back it up in the /doc folder. You can also find a real crappy formatter for z80dasm output in /src.  Its mostly ai generated slop but works. I haven't bothered to teach myself Gehdra, I suppose that is better suited for projects like this.  I like making my own toolchains and its simple enough to work just in vscode which makes my brain happy.
</p>
<p>
If you would like to pick at this and do a pull request please do! I just ask you don't mess with the format that is placed by the tool because I would really like to make a formatter that can pull the asembly out and make a file we can asemble.  This format will make it easy.  Simply put comments after  ;  and do 6 spaces after the numonics / operands, don't mess with the spacing or addressing otherwise.
</p>