# Requirements #
  * MATLAB installation. The code has only been tested in MATLAB R2010b, though a free variant such as [Octave](http://www.gnu.org/software/octave/), [Scilab](http://www.scilab.org/), [FreeMat](http://freemat.sourceforge.net/) may also work (see FAQ: What if I don't have MATLAB?).
  * C# compiler or [Microsoft .Net development framework](http://www.microsoft.com/net/). [Microsoft Visual C# express 2010](http://www.microsoft.com/visualstudio/en-us/products/2010-editions/visual-csharp-express) is one such option.

# Getting the Code #
If you want to grab the latest code, you can do so over http or with any SVN client from [here](http://code.google.com/p/matlabadin/source/checkout). Save the directory structure to someplace that your MATLAB and C# installations can get to. For the MATLAB portions, you're done!

# Compiling the C# Portion #
The C# code that handles the FSM logic can be found in the [RotationCalculator/Matlabadin](http://code.google.com/p/matlabadin/source/browse/#svn%2Ftrunk%2FRotationCalculator%2FMatlabadin) folder within the trunk.

MATLAB should handle the compilation of the C# modules automagically, assuming you have a C# compiler where MATLAB can find it.


# Warnings #
We cannot guarantee that the code will run flawlessly or compile without errors, problems, etc. If you report an issue, and it is within our power to fix it, we'll try to get it addressed. Please see the [FAQ](matlabadinFAQ.md) if you have any questions.