; (document
;   root: (element
;     (STag
;       (Name) @name.project (#eq? @name.project "Project"))
;     (content
;       (element
;         (STag
;           (Name) @name.pgroup (#eq? @name.pgroup "PropertyGroup"))
;         (content
;           (element
;             (STag
;               (Name) @name.tframe (#eq? @name.tframe "TargetFramework"))
;             (content 
;               (CharData) @dotnet_version))
;           (element
;             (STag
;               (Name) @name.iusing (#eq? @name.iusing "ImplicitUsings"))
;             (content
;               (CharData) @implicit_usings))
;           (element
;             (STag
;               (Name) @name.langver (#eq? @name.langver "LangVersion"))
;             (content
;               (CharData) @lang_version)))))))


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
