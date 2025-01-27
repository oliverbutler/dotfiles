; Match JavaScript in Script(g.Raw(`...`)) patterns, even when deeply nested
((call_expression
  function: (identifier) @_func
  arguments: (argument_list
    (call_expression
      function: (selector_expression
        operand: (identifier) @_g
        field: (field_identifier) @_raw)
      arguments: (argument_list
        (raw_string_literal
          (raw_string_literal_content) @injection.content)))))
  (#eq? @_func "Script")
  (#eq? @_g "g")
  (#eq? @_raw "Raw")
  (#set! injection.language "javascript"))

; Match JavaScript in g.Attr("onclick", `...`) patterns
((call_expression
  function: (selector_expression
    operand: (identifier) @_g
    field: (field_identifier) @_attr)
  arguments: (argument_list
    (interpreted_string_literal) @_event
    (raw_string_literal
      (raw_string_literal_content) @injection.content)))
  (#eq? @_g "g")
  (#eq? @_attr "Attr")
  (#match? @_event "^\"onclick\"")
  (#set! injection.language "javascript"))

; Match SQL in s.db.Pool.Query/QueryRow/Exec (raw string literals)
((call_expression
  function: (selector_expression
    operand: (selector_expression
      operand: (selector_expression
        operand: (identifier) @_s
        field: (field_identifier) @_db)
      field: (field_identifier) @_pool)
    field: (field_identifier) @_query)
  arguments: (argument_list
    (_)  ; context argument
    (raw_string_literal
      (raw_string_literal_content) @injection.content)
    . ; Allow for additional arguments after the SQL
    (_)*))  ; Match zero or more trailing arguments
  (#eq? @_s "s")
  (#eq? @_db "db")
  (#eq? @_pool "Pool")
  (#match? @_query "^(Query|QueryRow|Exec)$")
  (#set! injection.language "sql"))

