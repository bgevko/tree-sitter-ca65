(directive_name) @keyword
(procstart) @keyword
(procend) @keyword
(macrostart) @keyword
(macroend) @keyword

(proc name: (identifier) @function)

(mnemonic) @function.builtin

(assignment name: (identifier) @variable)
(assignment operator: (_) @operator)
(assignment value: (anything) @constant)

(base) @type
(immediate) @variable
(address_expression) @variable
(register) @constant.builtin

(string) @string
(char) @string
(number) @number
(comment) @comment
(label (identifier) @tag)
(label (local_identifier) @tag)
(label (unnamed_label) @tag)
(unnamed_label_ref) @tag
(operator) @operator
(separator) @punctuation.delimiter
(bracket) @punctuation.bracket
(immediate_marker) @punctuation.delimiter 
