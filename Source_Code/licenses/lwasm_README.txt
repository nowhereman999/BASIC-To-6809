The official distribution point for lwtools is
http://lwtools.projects.l-w.ca/. If you obtained this distribution from any
other place, please visit the official site. You may have a modified or out
of date version.

This is LWTOOLS, a cross development system targetting the 6809 CPU.

It consists of an assembler, lwasm, a linker, lwlink, and an archiver,
lwar which should compile on any reasonably modern POSIX environment. If you
have problems building, make sure you are using GNU make. Other make
programs may work but GNU make is known to work.

There is some source code support for building with Microsoft's compiler on
Windows. However, this has been contributed by interested users and is not
well tested. Indeed, the primary maintainer has no access to such a system.

To see if a quick build will work, just type "make". If it works, you're
ready to go ahead with "make install". This will install in /usr/local/bin.

If you feel adventurous, you can also run the test suite by running "make
test". However, be warned that it is likely not going to work unless you are
running on a fairly standard unix system with perl in /usr/bin/perl.

See docs/ for additional information.

CONTRIBUTING
============

If you wish to contribute patches or code to lwtools, please keep the
following in mind.

Evangelism
----------

Any communication that includes evangelism for alternate revision control
systems, coding styles, development methodologies, or similar will be
deleted with all other contents ignored. So just don't do it and save
yourself and the project maintainers time.

Style
-----

The code formatting style must match the rest of the lwtools code. Code
submitted in the "1TBS" will be rejected out of hand. Attempts to convince
me to change my mind on this point will be routed to /dev/null at best and
likely met with extreme rudeness.

C code should be formatted as follows:

* In general, match the formatting of the surrounding code, whether that
  uses spaces or tabs. Otherwise, all indentation uses a single TAB
  character for each step. That is a HARD tab, not a series of spaces. TABs
  are assumed to be 4 characters though that will largely impact only lining
  up comments and tabular code. If the actual formatting of the code is
  critical, spaces may be used for that formatting but the actual initial
  indentation of the lines MUST use TAB characters.
* The opening brace for a block appears on the line below the control
  structure that introduces it. It appears lined up with the preceding line
  and nothing else appears on the same line.
* Closing braces appear on a line by themselves ordinarily. The exception is
  the "while" keyword in a "do-while" statement appears on the same line as
  the closing brace for the block.
* Case labels are lined up with the enclosing block (one level back from the
  code of the block). The same guideline applies for ordinarily labels.
* No spaces surround parentheses, brackets, or the dot operator. No space
  precedes a comma but a space should follow it. Other operators should
  usually be surrounded by spaces. A space should separate a keyword from
  any surrounding except for sizeof() which should be written like a
  function call. There is no space between a function name and the start of
  its parameter list.

In general, study the existing source formatting and copy the style. This is
what you should do anyway and the above should not be required.

For code accepted to the contrib/ hierarchy, application of the above coding
style may be less strict.

Submitting
----------

Any attempts to evangelize git or any other alternative revision control
system will be deleted with *all* other contents ignored.

When submitting code to lwtools, it should be submitted as a patch file (hg
diff or diff -u). DO NOT submit entire source files. Remember, others may be
working on changes, too, and your complete source files are difficult to
merge with such situations. By submitting complete source files, you are
making far more work for the maintainer and it is generally considered rude.

Always specify what version of the source you based your patch on. If
possible, work off the default branch in the mercurial repository. At the
very least, make sure you are working with the most recent release.

It is also worth checking with the maintainer before submitting a patch.
There may be some reason why your pet feature is not present in the official
release.

Finally, be prepared to receive a list of deficiencies or requests for
improvements or clarification of why or how you did something.
