JPS Document Generator

The Document Generator will scan 4 different File Types,
the files are searched for comments beginning with --[[[ and end with ]]--
The comments are searched for tags (beginning with @), everything that follows a tag is counted towards it's content until the
next tag is found.
Invalid Tags or words preceeding the first tag are ignored.
The content can be plain HTML code or a limited number of BB Code Elements (for detailed information on which BB Code is supported,
you might want to look at the dictionary BB_CODE in the gendoc.py script).
Additional you can reference other functions with #ref:<function name>.


1. Modules
Everything needed for normal Rotation Editing - All file should be in the 'modules' directory.

The first comment is regarded as the module comment, supported Tags:
@module      - Name of the Module
@description - Extended Description of the Module

After the first comment all other comments are regarded as function comments, supported Tags:
@function    - Name of the function
@description - Extended Description of the function
@param       - Parameter, first word is the parameter name, the rest is the description of the parameter - this tag can occur 
                multiple times - one param for each parameter
@returns     - Description of the returned value
@deprecated  - Adds a warning to the documentation, that this function is deprecated. Any text after the tag is added to this warning

The Glob List is MODULE_GLOBS.


2. Advanced Functionality
More advanced functionality which isn't in the normal rotation but might be handy (e.g. adding your own events).
The Tags are the same as in Modules
The Glob List is ADVANCED_GLOBS.


3. Rotations
Description of the Rotations, all files in the 'Rotations' dir are scanned.
All comments are regarded as a Rotation, supported Tags:
@rotation     - Name of the rotation
@class        - Class-Name (english!)
@spec         - Full Spec Name (english!)
@talents      - Talent Calculater String from the official Talent Calculater (http://eu.battle.net/wow/en/tool/talent-calculator#U!20.120!YXQr becomes U!20.120!YXQr)
@deprecated   - Adds a warning to the documentation, that this rotation is deprecated, Any text after the tag is added to this warning
@description  - Extended Description of the rotation


The Glob List is ROTATION_GLOBS.


4. ToDo's
List of open ToDo's in the JPS source files. All lua files should be scanned.
All files are scanned for comments beginning with --JPTODO: - the preceding text is added as ToDo in the documentation.
