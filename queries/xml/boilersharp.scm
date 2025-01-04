(document
  root: (element
    (STag
      (Name) @name.project (#eq? @name.project "Project"))
    (content
      (element
        (STag
          (Name) @name.pgroup (#eq? @name.pgroup "PropertyGroup"))
        (content
          (element
            (STag
              (Name) @key)
            (content 
              (CharData) @value)))))))
