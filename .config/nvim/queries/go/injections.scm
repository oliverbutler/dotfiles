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

