:Namespace Snippets_UC
⍝ This script directs calls to the Snippets user commands to Snippets itself.
⍝ It's just an interface that does not do anything by itself.
⍝ Version 0.1.0 ⋄ 2024-03-14 ⋄ Kai Jaeger

    ∇ PrintError dummy;msg
      msg←''
      :If 3=⎕NC'⎕SE.Snippets.Version'
          msg←' Snippets is not installed correctly. Please remove and install again.'
      :EndIf
      ⎕←msg
    ∇

    ∇ r←List;ref
      r←''
      :If 9=⎕NC'⎕SE.Snippets'
          ref←GetRefToSnippets''
          :If 3=ref.⎕NC'List'
              r←ref.List
          :Else
              PrintError''
          :EndIf
      :EndIf
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
      :If 9=⎕NC'⎕SE.Snippets'
          ref←GetRefToSnippets''
          :If 3=ref.⎕NC'Run'
              r←ref.Run(cmd args)
          :Else
              PrintError''
          :EndIf
      :Else
          ⎕←'Snippets not found'
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
