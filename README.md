# Snippets

**Note that this project is work in progress.**

A few bits are not implemented yet (notably the `]Snippets.Compare` command) but the basics work fine.

I am keen to get feedback on this.

## Overview

What are snippets?

A snippet can be a function, an operator, a class, an interface, a namespace script, a variable or just a piece of code.

Snippets are useful pieces of code or data in circumstances that occur relatively frequently, but they do not qualify for becoming a package.

Take this code, for example:

```
Assert←{⍺←'' ⋄ (,1)≡,⍵:r←1 ⋄ ⎕ML←1 ⋄ ⍺ ⎕SIGNAL 1↓(⊃∊⍵),11}
```

This certainly does not qualify as a package: there is no need for versioning or documentation, and no dependencies either.

But you might use this piece of code frequently enough to make it available as a snippet, because this is not something that can easily be entered on the fly, not to mention the possibility of a typo, making it a perfect example of a snippet.

The Dyalog APL user command `]Snippets` allows you to create, list and inspect snippets, and get them into the workspace in one way or another.


## Examples

```
      ]Snippets.List
 *** Folder:     C:\Users\...\Documents\MyUCMDs\Snippets\.snippets/                                              
 Assert          Takes Boolean ⍵ and returns it if true but signals an error otherwise                  
 History         Returns all "leading" comments as a vector of characters vectors               
 Make            "Make" a new version of this project                                                            
 Split           (≠⊆⊢)                                                                                           
 Version         Fetches the version number from the package config file                                         
      ]SNIPPETS.View Ass*
 Assert←{⍺←'' ⋄ (,1)≡,⍵:r←1 ⋄ ⎕ML←1 ⋄ ⍺ ⎕SIGNAL 1↓(⊃∊⍵),11} ⍝ Takes a Boolean as ⍵ and and returns it if true but signals an error otherwise 
      ]SNIPPETS.Fix Ass*
"Assert" fixed in #
      'Tell something' Assert 1
      'Tell something' Assert 0
Tell something
      'Tell something'Assert 0
                      ∧
      #.variable←'This' 'is' 'a' 'nested' 'vector'
      ]Snippets.Save #.variable -name=MyStuff-variable 
```


## Commands

```
      ]Snippets -??
                                                                           
 SNIPPETS:                                                                 
  Compare   Compare an object in the workspace with a saved snippet       
  Copy      Copy a snippet to the clipboard (Windows only)                 
  Delete    Delete a snippet                                               
  Edit      Edit a snippet                                                 
  Fix       Fix a snippet in the workspace                                   
  Help      Provide a help page explaining the principles                 
  List      List all saved snippets                                        
  Save      Save a function or operator or script or a piece of code as a snippet            
  Show      Put a snippet into ⎕ED  
  Version   Return the version number                                     
```


## Installation

`Snippets` can be installed as a Tatin package:

```
]Tatin.InstallPackages [tatin]Snippets [MyUCMDs]
```

This will make the user commands of `Snippets` available. Note that `Snippets` does not offer an API.


