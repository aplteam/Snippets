:Class Snippets_UC
⍝ User Command class for the "Snippets" manager
⍝ Kai Jaeger
⍝ 2024-01-11

    ⎕IO←1 ⋄ ⎕ML←1

    Extensions←'.aplf' '.aplo' '.aplc' '.apln' '.apli' '.dyalog' '.code'

    ∇ r←List;c ⍝ this function usually returns 1 or more namespaces (here only 1)
      :Access Shared Public
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
      c.Desc←'Provide a help page explaining the pronciples'
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

    ∇ r←Run(Cmd Args);folder;⎕TRAP;SN
      :Access Shared Public
      r←0 0⍴''
      :If 0=⎕SE.⎕NC'Snippets'
          {}⎕SE.Tatin.LoadDependencies(⊃⎕NPARTS ##.SourceFile)'⎕SE'
      :EndIf
      SN←⎕SE.Snippets
      :Select ⎕C Cmd
      :Case ⎕C'List'
          r←List_ Args
      :Case ⎕C'Edit'
          r←Edit_ Args
      :Case ⎕C'Copy'
          r←Copy_ Args
      :Case ⎕C'Fix'
          r←Fix_ Args
      :Case ⎕C'Save'
          r←Save_ Args
      :Case ⎕C'Delete'
          r←Delete_ Args
      :Case ⎕C'Compare'
          r←Compare_ Args
      :Case ⎕C'Show'
          r←Show_ Args
      :Case ⎕C'Help'
          r←Help_ Args
      :Case ⎕C'Version'
          r←Version_
      :Else
          ∘∘∘ ⍝ Huh?!
      :EndSelect
    ∇

    :Section MainFunctions

    ∇ r←_ ns
      r←{{⍵↑⍨¯1+⌊/⍵⍳'+"'}1↓⍵/⍨{⍵∨≠\⍵}⍵='"'}{⍵⊃⍨1⍳⍨∨/¨'version:'∘⍷¨⍵}(⎕UCS 13)(≠⊆⊢)SN.TatinVars.CONFIG
    ∇

    ∇ r←Compare_ ns
      r←'Sorry, not implemented yet'
    ∇

    ∇ r←Help_
      r←0 0⍴''
      ⎕SE.ADOC.Browse SN
    ∇

    ∇ r←Version_
      r←'0.4.0'
    ∇

    ∇ msg←Edit_ ns;opCode;name;filename;ref;body;body2
      (opCode msg name filename)←'SelectSnippetForEdit@Please select snippet to be edited'GetNameAndFilename ns
      :If 1=opCode
          (name body)←GetNameAndBody filename
          ref←EstablishCodeInNamespace body
          ref.⎕ED name
          body2←GetCodeFromWS ref name
          :If ≡/body body2
              msg←'No change detected'
          :ElseIf 0=≢(∊body2)~⎕UCS 10 13
              msg←'Cancelled by user' ⋄ →0
          :ElseIf SN.CommTools.YesOrNo'Sure you want to save "',name,'" ?'
              (⊂body2)SN.FilesAndDirs.NPUT filename 1
          :Else
              msg←'Cancelled by user' ⋄ →0
          :EndIf
      :EndIf
    ∇

    ∇ msg←Save_ ns;cl;body;name;extension;filename;ref;qdmx;q;parent;nc;name_
      :If 0=≢ns.Arguments
          'cl'⎕WC'Clipboard'
          body←⊆cl.Text
          :If 0=≢name←''ns.Switch'name'
              name←({ns←⎕NS'' ⋄ 0=ns.⎕NC ⍵:1 ⋄ ⎕←'Please enter a valid APL name' ⋄ 0}SN.CommTools.AskForText)'name@Specify the name of the snippet'
          :EndIf
          :If 0=≢name
              msg←'Cancelled by user' ⋄ →0
          :EndIf
      :Else
          name←ns._1
          :If '.'∊name
              parent←{⍵↓⍨-'.'⍳⍨⌽⍵}name
              ('Object not found',name)Assert 0<≢parent
          :Else
              parent←⊃{⍵/⍨~'['∊¨⍵}{⍵↓⍨+/∧\'⎕se'∘≡¨3↑¨⎕C ⍵}⎕NSI
              nc←(⍎parent).⎕NC name
              :If nc=¯1
                  msg←'Invalid snippet name' ⋄ →0
              :ElseIf nc=0
                  msg←'Name has no value?!' ⋄ →0
              :EndIf
          :EndIf
          :If ~(⊂,1 ⎕C parent)∊,¨'#' '⎕SE'
              ('Parent object not found: ',parent)Assert 9=⎕NC parent
          :EndIf
          parent←⍎parent
          :Select ⊃parent.⎕NC name
          :Case ¯1
              ('Name <',name,'> is invalid')⎕SIGNAL 6
          :Case 0
              ('<',name,'> not found in ',⍕parent)⎕SIGNAL 6
          :Case 2
              body←parent⍎ns._1
              body←⎕SE.Dyalog.Array.Serialise body
          :Case 9
              body←⎕SRC parent⍎name
          :CaseList 3 4
              body←parent.⎕NR name
          :Else
              ∘∘∘  ⍝ Huh?!
          :EndSelect
      :EndIf
      :If 0=≢body
          msg←'No name was specified, and the clipboard does not contain code?!'
      :Else
          :If 2=⎕NC'parent'
              nc←parent.⎕NC name
          :Else
              nc←2
          :EndIf
          :If nc∊2 3 4
              extension←(2 3 4⍳nc)⊃'.apla' '.aplf' '.aplo'
          :Else
              nc←parent.⎕NC⊂name
              extension←(9.1 9.4 9.5⍳nc)⊃'.apln' '.aplc' '.apli'
          :EndIf
          name_←{⍵↑⍨-¯1+'.'⍳⍨⌽⍵}name
          filename←GetHomeFolder,name_,extension
          :If SN.FilesAndDirs.IsFile filename
              q←'The file already exists - overwrite?'
              :If SN.CommTools.YesOrNo q
                  SN.FilesAndDirs.DeleteFile filename
              :Else
                  msg←'Cancelled by user' ⋄ →0
              :EndIf
          :ElseIf SN.FilesAndDirs.IsDir filename
              msg←'Cannot continue: ',filename,' is a directory' ⋄ →0
          :EndIf
          :Trap 0
              ref←name_{ns←⎕NS'' ⋄ _←⍎'ns.',⍺,'←,/⍵,¨⎕UCS 10' ⋄ ns}body
          :Else
              qdmx←⎕DMX
              msg←qdmx.EM{0=≢⍵:⍺ ⋄ ⍵}qdmx.Message ⋄ →0
          :EndTrap
          (⊂body)SN.FilesAndDirs.NPUT filename
          msg←'Code snippet successfully saved as ',⊃,/1↓⎕NPARTS filename
      :EndIf
    ∇

    ∇ msg←Delete_ ns;filenames;snippetNames;ind;name;msg
      (filenames snippetNames ind name msg)←CollectSnippetInfo'to copy to clipboard'({0≡⍵:'' ⋄ ⍵}ns._1)
      :If 0<≢name
          :If SN.FilesAndDirs.DeleteFile ind⊃filenames
              msg←'Snippet deleted: ',name
          :EndIf
      :EndIf
    ∇

    ∇ msg←Fix_ ns;folder;filenames;snippetNames;name;ind;index;body;q;buff;parent;qdmx;isVars;extension;res
      (filenames snippetNames ind name msg)←0 CollectSnippetInfo'to fix in the workspace'({0≡⍵:'' ⋄ ⍵}ns._1)
      :If 'Cancelled by user'≢msg
          parent←''ns.Switch'target'
          :If 0<≢name
              :If 0=≢parent
                  :If (,'#')≢parent←⊃{⍵/⍨~'['∊¨⍵}{⍵↓⍨+/∧\'⎕se'∘≡¨3↑¨⎕C ⍵}⎕NSI
                      index←'WhereToFix@Where do you want to fix it:'SN.CommTools.Select(⊂,'#'),⊂parent
                      :If 0=≢index
                          msg←'Cancelled by user' ⋄ →0
                      :EndIf
                      parent←⍎index⊃'#'parent
                  :Else
                      parent←#
                  :EndIf
              :Else
                  parent←⍎parent
              :EndIf
              body←GetCodeFromFile ind⊃filenames
              extension←3⊃⎕NPARTS ind⊃filenames
              :If isVars←'.apla'≡extension
                  name←2⊃⎕NPARTS ind⊃filenames
              :Else
                  body←{2=⍴⍴⍵:⍵ ⋄ ,⊆⍵}body
                  :Trap 0
                      name←GetNameFromBody body
                  :Else
                      qdmx←⎕DMX
                      qdmx.EM ⎕SIGNAL qdmx.EN
                  :EndTrap
                  :If name≢2⊃⎕NPARTS ind⊃filenames
                  :AndIf ~SN.CommTools.YesOrNo'DifferentName@Will be fixed as "',name,'"; you okay with that?'
                      msg←'Cancelled by user' ⋄ →0
                  :EndIf
              :EndIf
              :Select ⊃parent.⎕NC name
              :Case 0
              ⍝ Name is okay and not in use, nothing to do
              :Case ¯1
                  ('Invalid name: ',name)⎕SIGNAL 11
              :Else
                  q←'"',name,'" already used in ',(⍕parent),'; overwrite?'
                  :If 0=SN.CommTools.YesOrNo q
                      msg←'Cancelled by user' ⋄ →0
                  :EndIf
                  parent.⎕EX name
              :EndSelect
              :If (⊂extension)∊'.aplf' '.aplo'
                  buff←parent.⎕FX body
                  :If ' '=1↑0⍴∊buff
                      msg←'Function "',name,'" fixed in ',⍕parent
                  :Else
                      msg←'Attempt to fix "',name,'" caused an error in line ',⍕buff
                  :EndIf
                  res←⎕SE.Link.Add(⍕parent),'.',name
                  :If 'Added:'{⍺≡(≢⍺)↑⍵}res
                      msg,←'; ',res
                  :EndIf
              :ElseIf isVars
                  ⍎(⍕parent),'.',name,'←body'
                  msg←'Variable "',name,'" assigned in "',(⍕parent),'"'
              :Else
                  :Trap 0
                      {}parent.⎕FIX body
                      msg←'Script "',name,'" fixed in ',⍕parent
                  :Else
                      msg←'Attempt to fix "',name,'" caused an error'
                  :EndTrap
              :EndIf
          :Else
              msg←'No such (fixable) snippet found'
          :EndIf
      :EndIf
    ∇

    ∇ msg←Copy_ ns;name;ind;cl;success;filenames;snippetNames
      :If 'Win'≡3↑1⊃'#'⎕WG'APLVersion'
          (filenames snippetNames ind name msg)←CollectSnippetInfo'to copy to clipboard'({0≡⍵:'' ⋄ ⍵}ns._1)
          :If 0=≢msg
              success←0
              :Repeat
                  :Trap 0 ⍝ Yes, this fails occasionally under Windows for no reason at all
                      'cl'⎕WC'Clipboard'
                      cl.Text←GetCodeFromFile ind⊃filenames
                      success←1
                  :Else
                      ⎕DL 0.01
                  :EndTrap
              :Until success
              msg←'Copied to the clipboard: ',ind⊃snippetNames
          :EndIf
      :Else
          msg←'This command is only available on Windows'
      :EndIf
    ∇

    ∇ r←List_ ns;folder;list;comments;bool;list2;name;full;ind
      r←'No snippets found'
      folder←GetHomeFolder
      list←SN.FilesAndDirs.ListFiles folder
      full←ns.Switch'full'
      :If 0<≢list
          list2←{⊃,/1↓⎕NPARTS ⍵}¨list
          name←ns._1
          :If 0≢name
              :If '*'∊name
                  bool←(name~'*'){(⎕C ⍺)∘≡¨⎕C(≢⍺)↑¨⍵}list2
              :Else
                  bool←(⎕C list2)≡¨⊂⎕C name
              :EndIf
              (list list2)←bool∘/¨list list2
          :EndIf
      :AndIf 0<≢list
          :If full
              r←list
          :Else
              r←list2
          :EndIf
          :If ns.Switch'short'
              r←⍪(⊂'*** Folder: ',folder),' ',¨r
          :Else
              comments←GetComment¨list
              :If 0<≢ind←⍸{'.code'≡3⊃⎕NPARTS ⍵}¨list
                  comments[ind]←∊∘GetCodeFromFile¨list[ind]
              :EndIf
              r←r,[1.5]comments
              r←'*** Folder:'folder⍪r
          :EndIf
          r←⍕r
          r←CutWidth r
      :EndIf
    ∇

    ∇ r←Show_ ns;opCode;msg;name;filename;session;ref;body
      r←''
      (opCode r name filename)←'SelectSnippetForView@Please select snippet to be shown with ⎕ED'GetNameAndFilename ns
      :If 1=opCode
          session←ns.Switch'session'
          :If session
              r←⊃SN.FilesAndDirs.NGET filename 1
              :If '.apla'≡3⊃⎕NPARTS filename
                  r←⎕SE.Dyalog.Array.Deserialise r
              :EndIf
              r←⍪↓DLB↑r
              r←(⊂(⎕PW-5)⍴'-')⍪r
          :Else
              (name body)←2↑GetNameAndBody filename
              :If '.apla'≡3⊃⎕NPARTS filename
                  ref←name EstablishVarsInNamespace body
              :Else
                  ref←EstablishCodeInNamespace body
              :EndIf
              ref.{{}(⎕ED⍠('ReadOnly' 1)&⍵)}name
          :EndIf
      :EndIf
    ∇

    :Endsection

    :Section Help

    ∇ r←level Help Cmd;ref
      :Access Shared Public
      r←''
      :Select level
      :Case 0
          :Select ⎕C Cmd
          :Case ⎕C'List'
              r,←⊂'List all saved snippets with the first comment line unless -short is specified'
              r,←⊂']Snippets.List [name*] -short -full'
          :Case ⎕C'Edit'
              r,←⊂'Edit a snippet'
              r,←⊂']Snippets.Edit [name*]'
          :Case ⎕C'Copy'
              r,←⊂'Copy a snippet to the clipboard (Windows only)'
              r,←⊂']Snippets.Copy [name*]'
          :Case ⎕C'Fix'
              r,←⊂'Fix a snippet in the workspace'
              r,←⊂']Snippets.Fix <name> -target='
          :Case ⎕C'Save'
              r,←⊂'Save a function or operator or script or a piece of code as a snippet'
              r,←⊂']Snippets.Save [name] -name='
          :Case ⎕C'Delete'
              r,←⊂'Delete a saved snippet'
              r,←⊂']Snippets.Delete [name*] -force'
          :Case ⎕C'Compare'
              r,←⊂'Compare a function, operator or script with a saved snippet'
              r,←⊂']Snippets.Compare <object-name>'
          :Case ⎕C'Show'
              r,←⊂'Bring the code of a snippet into ⎕ED'
              r,←⊂']Snippets.Show [<name*>] -session'
          :Case ⎕C'Version'
              r,←⊂'Return the version number of the snippet manager'
              r,←⊂']Snippets.Version'
          :EndSelect
          :If ~(⊂⎕C Cmd)∊⎕C'Version' 'Help'
              r,←''(']Cider.',Cmd,' -?? ⍝ Enter this for more information ')
          :EndIf
      :Case 1
          :Select ⎕C Cmd
          :Case ⎕C'List'
              r,←⊂'Lists all saved snippets with the first comment line unless -short is specified.'
              r,←⊂'In case -full is specified the full filename rather than just the snippet name is shown.'
              r,←⊂''
              r,←⊂'* If no name is given all snippets are listed'
              r,←⊂'* If something is specified all snippets that start with the argument are listed'
              r,←⊂'  The search is not case sensitive.'
              r,←⊂'* In case -short is specified only the names are listed but no comments'
          :Case ⎕C'Edit'
              r,←⊂'Allows you to edit a snippet as if it were a variable in the workspace.'
              r,←⊂''
              r,←⊂'* If no argument is specified all snippets are listed and you may select one'
              r,←⊂'* If an argument is specified but carries a trailing asterisk all snippets with'
              r,←⊂'  corresponding names are listed. The search is not case sensitive.'
              r,←⊂'* If an argument is specified without a trailing asterisk the name given must match a'
              r,←⊂'  snippet, otherwise an error is signalled. The search is not case sensitive.'
          :Case ⎕C'Copy'
              r,←⊂'Copies a snippet to the clipboard (Windows only)'
              r,←⊂''
              r,←⊂'* If no argument is specified all snippets are listed and the user may select one'
              r,←⊂'* If an argument is specified but carries a trailing asterisk all snippets with'
              r,←⊂'  corresponding names are listed for selection. The search is not case sensitive.'
              r,←⊂'* If an argument is specified without a trailing asterisk, a snippet with that name'
              r,←⊂'  will be copied. The search is not case sensitive.'
          :Case ⎕C'Fix'
              r,←⊂'Fixes a snippet into the workspace'
              r,←⊂''
              r,←⊂'* If no argument is specified all snippets are listed except those stored in .code'
              r,←⊂'  files: they cannot be fixed by definition. The user can then select one of them.'
              r,←⊂'* If an argument is specified but carries a trailing asterisk all snippets with'
              r,←⊂'  corresponding names are listed for selection. The search is not case sensitive.'
              r,←⊂'* If an argument is specified without a trailing asterisk a snippet with that name'
              r,←⊂'  will be fixed. The search is not case sensitive.'
              r,←⊂'  If no snippet is found an error is signalled.'
              r,←⊂'* If -target is not specified the snipped will be fixed in # unless the user is'
              r,←⊂'  currently in a sub-namespace of #, when the user will be asked what to do.'
          :Case ⎕C'Save'
              r,←⊂'Saves a function or operator or script as a snippet'
              r,←⊂''
              r,←⊂'* If an argument is specified it is interpreted as a fully qualified name to the'
              r,←⊂'  function, operator or script to be saved'
              r,←⊂'* By default the name of the APL object defines the name of the snippet'
              r,←⊂'* With the -name= option you can specify a different name'
              r,←⊂'* If no argument is specified at all and there is text on the clipboard the user'
              r,←⊂'  command assumes that you want to save the clipboard content as a snippet'
              r,←⊂'  In this case a confirmation is required.'
          :Case ⎕C'Delete'
              r,←⊂'Deletes a saved snippet'
              r,←⊂''
              r,←⊂'* When an argument is specified any matching snippet will be deleted. The search will'
              r,←⊂'  not be case sensitive. If the argument carries a trailing asterisk all matching'
              r,←⊂'  snippets will be presented for selection.'
              r,←⊂'* The user must always confirm a delete operation except when -force is specified'
              r,←⊂'* When no argument is specified all snippets will be presented for selection'
              r,←⊂'* -force has no effect in case the user is presented a list with more than one snippet'
          :Case ⎕C'Compare'
              r,←⊂'Compares a function, operator or script with a saved snippet'
              r,←⊂''
              r,←⊂'This command requires at least one argument and accepts up to two.'
              r,←⊂''
              r,←⊂'* A single argument is interpreted as the name of an APL object. If it is not fully'
              r,←⊂'  qualified it is assumed to live in the namespace the user command was called from.'
              r,←⊂'* A second argument must be the name of a snippet. If this is not specified the user'
              r,←⊂'  will be presented a list withh all snippets for selection.'
              r,←⊂'* If the second argument carries a trailing asterisk all matching snippets will be'
              r,←⊂'  presented for selection. The search will not be case sensitive.'
              r,←⊂'* If the user command ]CompareFiles (and its API) is available this will be used to'
              r,←⊂'  carry out the comparison, otherwise two files are printed to the session.'
              r,←⊂''
          :Case ⎕C'Show'
              r,←⊂'Brings the code of a given snippet into ⎕ED.'
              r,←⊂''
              r,←⊂'If a given name does not result in a match it is interpreted as "search for all that'
              r,←⊂'start with the given string". If several snippets match the user is given a list to'
              r,←⊂'select from. The search is case insensitive.'
              r,←⊂''
              r,←⊂'-session Prints the code to the session rather than bringing it into ⎕ED'
          :Case ⎕C'Version'
              r,←⊂'Returns the version number of the ]Snippets user command'
          :EndSelect
      :Case 2
          r,←⊂'There is no additional help available'
      :EndSelect
    ∇

    :EndSection

    :Section Utils

    Assert←{⍺←'' ⋄ (,1)≡,⍵:r←1 ⋄ ⍺ ⎕SIGNAL 1↓(⊃∊⍵),11}

    ∇ (opCode msg name filename)←caption GetNameAndFilename ns;list;list2;ind;ind2
    ⍝ opCodes:
    ⍝  0 = nothing to do (for example, no snippets found)
    ⍝  1 = All fine, carry on
    ⍝ ¯1 = Snippet not found
    ⍝ ¯2 = Cancelled by user
      msg←name←filename←''
      :If 0<≢list←SN.FilesAndDirs.ListFiles GetHomeFolder
          list2←{2⊃⎕NPARTS ⍵}¨list
          name←{0≡⍵:'' ⋄ ⍵}ns._1
          :If 0<≢name
              :If '*'∊name
                  ind←⍸(name~'*'){(⎕C ⍺)∘≡¨⎕C(≢⍺)↑¨⍵}list2
                  :If 1<≢ind
                      :If 0=≢ind2←caption SN.CommTools.Select list2[ind]
                          msg←'Cancelled by user' ⋄ opCode←¯2 ⋄ →0
                      :EndIf
                      ind←ind[ind2]
                  :EndIf
              :Else
                  :If 0=≢ind←⍸(⎕C list2)≡¨⊂⎕C name
                      msg←'Snippet not found' ⋄ opCode←¯1 ⋄ →0
                  :EndIf
              :EndIf
          :Else
              :If 0=≢ind←caption SN.CommTools.Select list2
                  msg←'Cancelled by user' ⋄ opCode←¯2 ⋄ →0
              :EndIf
          :EndIf
          name←ind⊃list2
          filename←ind⊃list
          opCode←1
      :Else
          msg←'Cancelled by user' ⋄ opCode←¯2 ⋄
      :EndIf
    ∇

    ∇ name←GetNameFromBody body
      :If ∨/':class' ':namespace'{⍺≡(≢⍺)↑⍵}¨⊂⎕C' '~⍨⊃body
          name←{⍵↑⍨¯1+⍵⍳' '}{⍵↓⍨+⍵⍳' '}DLB⊃body
      :Else
          name←⊃(⎕NS'').{' '≠1↑0⍴∊⎕FX ⍵: ⋄ ' '~⍨¨↓⎕NL⍳16}body
      :EndIf
    ∇

    ∇ (name body)←GetNameAndBody filename;body
      body←⊃⎕NGET filename 1
      body←(-+/∧\0=⌽≢¨body)↓body
      :If '.apla'≡3⊃⎕NPARTS filename
          name←2⊃⎕NPARTS filename ⍝ For a variable the filename defines the name
          body←⎕SE.Dyalog.Array.Deserialise body
      :Else
          name←GetNameFromBody body
      :EndIf
    ∇

    ∇ ref←EstablishCodeInNamespace body
      ref←⎕NS''
      :If ∨/':class' ':namespace'{⍺≡(≢⍺)↑⍵}¨⊂⎕C' '~⍨⊃body
          ref.⎕FIX body
      :ElseIf
          ref.⎕FX body
      :EndIf
    ∇

    ∇ ref←name EstablishVarsInNamespace value
      ref←⎕NS''
      ⍎'ref.',name,'←value'
    ∇

    ∇ body←GetCodeFromWS(ref name);buff
      :If ref IsScripted name
          ∘∘∘  ⍝TODO⍝ Scripts are not yet supported
      :Else
          body←↓ref.⎕CR name
          body←{⍵↓⍨-+/∧\' '=⌽⍵}¨body
      :EndIf
    ∇

    ∇ body←GetCodeFromFile filename;buff
      body←⊃SN.FilesAndDirs.NGET filename 1
      :If '.apla'≡3⊃⎕NPARTS filename
          body←⎕SE.Dyalog.Array.Deserialise body
      :ElseIf 1=≢body
      :AndIf (⊂3⊃⎕NPARTS filename)∊'.aplf' '.aplo' '.code'
          buff←{⍵{⍵\⍵/⍺}{~⍵∨≠\⍵}''''=⍵}⊃body ⍝ Wipe out anything quoted
          body←⊂(¯1+buff⍳'⍝')↑⊃body
      :EndIf
      body←↓DLB↑body
    ∇

    ∇ r←{x}IsScripted y;ref
    ⍝ Returns a 1 for classes, interfaces and scripted namespaces and 0 otherwise.
      ref←{0<⎕NC'x':⍎⍵ ⋄ ⎕THIS}'x'
      r←ref.{11 16::0 ⋄ 1⊣⎕SRC ⍵}y
    ∇

    ∇ r←GetComment filename;body;buff
      body←⊃SN.FilesAndDirs.NGET filename 1
      :If 1=≢body
      :AndIf (⊂3⊃⎕NPARTS filename)∊'.aplf' '.aplo' '.code'
          buff←{⍵{⍵\⍵/⍺}{~⍵∨≠\⍵}''''=⍵}⊃body ⍝ Wipe out anything quoted
          r←DLB(buff⍳'⍝')↓⊃body
      :Else
          body←DLB¨{(+/∧\';'=⊃¨⍵)↓⍵}1↓body
          :If '⍝'=⊃⊃body
              r←DLB 1↓⊃body
          :Else
              r←''
          :EndIf
      :EndIf
    ∇

    ∇ r←CutWidth r;rows
      :If ⎕PW<1+2⊃⍴r
          rows←⍸∨/' '≠⎕PW↓[2]r
          r[rows;(⎕PW-3)+⍳3]←'.'
          r←⎕PW↑[2]r
      :EndIf
    ∇

    ∇ folder←GetHomeFolder
      folder←(⊃⎕NPARTS ##.SourceFile),'.snippets/'
      3 ⎕MKDIR folder
    ∇

      DLB←{
          2=⍴⍴⍵:⍵↓[2]⍨⌊/+/∧\' '=⍵
          1<≡⍵:∇¨⍵
          ⍵↓⍨+/∧\' '=⍵
      }

    ∇ (filenames snippetNames ind name msg)←{all}CollectSnippetInfo(caption txt);folder;ind2;bool;list2
      all←{0<⎕NC ⍵:⍎⍵ ⋄ 1}'all'
      filenames←snippetNames←msg←''
      folder←GetHomeFolder
      filenames←SN.FilesAndDirs.ListFiles folder
      :If 0=≢filenames
          msg←'No ',((~all)/'fixable'),' snippets found' ⋄ →0
      :EndIf
      :If all
          bool←1
      :Else
          bool←'.code'∘≢¨3⊃∘⎕NPARTS¨filenames
          filenames←bool/filenames
      :EndIf
      :If 0=≢filenames
          msg←'No ',((~all)/'fixable'),' snippets found' ⋄ →0
      :EndIf
      snippetNames←2⊃∘⎕NPARTS¨filenames
      name←''
      :If 0=≢txt
          txt←'*'
      :EndIf
      :If '*'∊name←txt
          ind←⍸(⎕C name~'*'){⍺∘≡¨⎕C(≢⍺)↑¨⍵}snippetNames
          :If 0=≢ind
              msg←'No match found' ⋄ name←'' ⋄ →0
          :EndIf
          :If 1=≢ind
              name←ind⊃snippetNames
          :Else
              list2←1↓↓bool{(1,(¯1+≢⍵)⍴⍺)⌿⍵}List_ ns
              ind2←('Select snippet ',caption)SN.CommTools.Select list2
              :If 0=≢ind2
                  name←''
                  msg←'Cancelled by user'
              :Else
                  ind←ind[ind2]
                  name←ind⊃snippetNames
              :EndIf
          :EndIf
      :Else
          ind←⍸(⎕C snippetNames)≡¨⊂⎕C name
          :If 0=≢ind
              msg←'No snippet found'
              name←''
          :Else
              name←ind⊃snippetNames
          :EndIf
      :EndIf
    ∇

    :EndSection

:EndClass
