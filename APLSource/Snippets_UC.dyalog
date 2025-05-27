:Namespace Snippets_UC
⍝ This script directs calls to the Snippets user commands to Snippets itself.
⍝ It's just an interface that does not do anything by itself.
⍝ Version 0.3.0 ⋄ 2025-05-27 ⋄ Kai Jaeger

    ∇ PrintError dummy;msg
      msg←''
      :If 3=⎕NC'⎕SE.Snippets.Version'
          msg←' Snippets is not installed correctly. Please remove and install again.'
      :EndIf
      ⎕←msg
    ∇

    ∇ r←List;c
      r←⍬

      c←⎕NS''
      c.Name←'List'
      c.Desc←'List all saved snippets'
      c.Group←'Snippets'
      c.Parse←'1s -short -full'
      r,←c
     
      c←⎕NS''
      c.Name←'Edit'
      c.Desc←'Edit a snippet'
      c.Group←'Snippets'
      c.Parse←'1s'
      r,←c
     
      c←⎕NS''
      c.Name←'Copy'
      c.Desc←'Copy a snippet to the clipboard (Windows only)'
      c.Group←'Snippets'
      c.Parse←'1s'
      r,←c
     
      c←⎕NS''
      c.Name←'Fix'
      c.Desc←'Fix a snippet in the workspace'
      c.Group←'Snippets'
      c.Parse←'1s -target='
      r,←c
     
      c←⎕NS''
      c.Name←'Save'
      c.Desc←'Save a function or operator or script or a piece of code as a snippet'
      c.Group←'Snippets'
      c.Parse←'1s -name='
      r,←c
     
      c←⎕NS''
      c.Name←'Delete'
      c.Desc←'Delete a snippet'
      c.Group←'Snippets'
      c.Parse←'1s -force'
      r,←c
     
      c←⎕NS''
      c.Name←'Show'
      c.Desc←'Show a snippet with ⎕ED'
      c.Group←'Snippets'
      c.Parse←'1s -session'
      r,←c
     
      c←⎕NS''
      c.Name←'Compare'
      c.Desc←'Compare an object in the workspace with a saved snippet'
      c.Group←'Snippets'
      c.Parse←'1-2'
      r,←c
     
      c←⎕NS''
      c.Name←'Help'
      c.Desc←'Provide a help page explaining the principles'
      c.Group←'Snippets'
      c.Parse←''
      r,←c
     
      c←⎕NS''
      c.Name←'Version'
      c.Desc←'Return the version number'
      c.Group←'Snippets'
      c.Parse←'0'
      r,←c
    ∇

    ∇ r←level Help cmd;ref
      r←0⍴⊂''
      :If 9=⎕NC'⎕SE.Snippets'
          ref←GetRefToSnippets''
          :If 3=ref.⎕NC'Help'
              r←level ref.Help cmd
          :Else
              PrintError''
          :EndIf
      :Else
          ⎕←'Snippets not found'
      :EndIf
    ∇

    ∇ r←Run(cmd args);ref
      r←''
      :If 0=⎕NC'⎕SE.Snippets'
     
      :Else
          ⎕←'Snippets not found'
      :EndIf
      ref←GetRefToSnippets''
      :If 3=ref.⎕NC'Run'
          r←ref.Run(cmd args)
      :Else
          PrintError''
      :EndIf
    ∇


    ∇ ref←GetRefToSnippets dummy;statuse
      :If 0<⎕SE.⎕NC'Link'
          statuse←⎕SE.Link.Status''
      :AndIf 2=⍴⍴statuse
      :AndIf (⊂'#.Snippets')∊statuse[;1]
      :AndIf 0<⎕SE.Snippets.⎕NC'DEVELOPMENT'
      :AndIf 0<⎕SE.Snippets.DEVELOPMENT
          ref←#.Snippets.Snippets
      :Else
          ref←⎕SE.Snippets
      :EndIf
    ∇

:EndNamespace
