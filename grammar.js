const 
  ca65mnemonic = [ 
    'adc', 'and', 'asl', 'bcc', 'bcs', 'beq', 'bit', 'bmi', 'bne', 'bpl', 'brk', 'bvc', 'bvs', 'clc', 'cld', 'cli', 'clv', 'cmp', 'cpx', 'cpy', 'dec', 'dex', 'dey', 'eor', 'inc', 'inx', 'iny', 'jmp', 'jsr', 'lda', 'ldx', 'ldy', 'lsr', 'nop', 'ora', 'pha', 'php', 'pla', 'plp', 'rol', 'ror', 'rti', 'rts', 'sbc', 'sec', 'sed', 'sei', 'sta', 'stx', 'sty', 'tax', 'tay', 'tsx', 'txa', 'txs', 'tya',
    'ADC', 'AND', 'ASL', 'BCC', 'BCS', 'BEQ', 'BIT', 'BMI', 'BNE', 'BPL', 'BRK', 'BVC', 'BVS', 'CLC', 'CLD', 'CLI', 'CLV', 'CMP', 'CPX', 'CPY', 'DEC', 'DEX', 'DEY', 'EOR', 'INC', 'INX', 'INY', 'JMP', 'JSR', 'LDA', 'LDX', 'LDY', 'LSR', 'NOP', 'ORA', 'PHA', 'PHP', 'PLA', 'PLP', 'ROL', 'ROR', 'RTI', 'RTS', 'SBC', 'SEC', 'SED', 'SEI', 'STA', 'STX', 'STY', 'TAX', 'TAY', 'TSX', 'TXA', 'TXS', 'TYA'
  ],
  ca65wdc = [
    'bra', 'brl', 'cop', 'dea', 'ina', 'jml', 'jsl', 'mvn', 'mvp', 'pea', 'pei', 'per', 'phb', 'phd', 'phk', 'phx', 'phy', 'plb', 'pld', 'plp', 'plx', 'ply', 'rep', 'rtl', 'sep', 'stp', 'stz', 'tcd', 'tcs', 'tdc', 'trb', 'tsb', 'tsc', 'txy', 'tyx', 'wai', 'xba', 'xce',
    'BRA', 'BRL', 'COP', 'DEA', 'INA', 'JML', 'JSL', 'MVN', 'MVP', 'PEA', 'PEI', 'PER', 'PHB', 'PHD', 'PHK', 'PHX', 'PHY', 'PLB', 'PLD', 'PLP', 'PLX', 'PLY', 'REP', 'RTL', 'SEP', 'STP', 'STZ', 'TCD', 'TCS', 'TDC', 'TRB', 'TSB', 'TSC', 'TXY', 'TYX', 'WAI', 'XBA', 'XCE'
  ],
  ca65rockwell = [
    /bbr[0-7]{0,1}/, /bbs[0-7]{0,1}/, /rmb[0-7]{0,1}/, /smb[0-7]{0,1}/,
    /BBR[0-7]{0,1}/, /BBS[0-7]{0,1}/, /RMB[0-7]{0,1}/, /SMB[0-7]{0,1}/
  ],
  ca65macpack = [
   'add', 'sub', 'bge', 'blt', 'bgt', 'ble', 'bnz', 'bze', 'jeq', 'jne', 'jmi', 'jpl', 'jcs', 'jcc', 'jvs', 'jvc',
   'ADD', 'SUB', 'BGE', 'BLT', 'BGT', 'BLE', 'BNZ', 'BZE', 'JEQ', 'JNE', 'JMI', 'JPL', 'JCS', 'JCC', 'JVS', 'JVC'
  ],
  ca65illegal = [
    'alr', 'anc', 'ane', 'arr', 'axs', 'dcp', 'isc', 'jam', 'las', 'lax', 'rla', 'rra', 'sax', 'sha', 'shx', 'shy', 'slo', 'sre', 'tas',
    'ALR', 'ANC', 'ANE', 'ARR', 'AXS', 'DCP', 'ISC', 'JAM', 'LAS', 'LAX', 'RLA', 'RRA', 'SAX', 'SHA', 'SHX', 'SHY', 'SLO', 'SRE', 'TAS'
  ],
  operators = [
    '+', '-', '/', '*', '<', '>', '!', '|', '&', '^', '=', ':'
  ],
  brackets = [
    '(', ')', '[', ']', '{', '}'
  ];

module.exports = grammar({
  name: 'ca65',

  conflicts: $ => [
    [$.address_expression],
    [$._expression, $.address_expression],
    [$.parenthesized_expression, $.address_expression],
  ],

  extras: $ => [
    /[ \t\r]+/,
    $.comment
  ],

  rules: {
    source_file: $ => seq(
      repeat(choice($._newline, seq($._item, $._newline))),
      optional($._item)
    ),

    _item: $ => choice(
      $.directive_line,
      $._statement,
      $.generic_line,
      $._preproc,
      $.assignment
    ),

    _block_item: $ => choice(
      $.directive_line,
      $._statement,
      $.generic_line,
      $._preproc,
      $.assignment
    ),

    _newline: $ => /\r?\n/,

    _statement: $ => choice(
      $.label,
      $.instruction,
      prec(1, seq(
        $.label,
        $.instruction
      ))
    ),

    instruction: $ => prec.right(1, seq(
      field('mnemonic', $.mnemonic),
      optional(field('operand', $._operand))
    )),

    mnemonic: $ => token(choice(
      ...ca65mnemonic,
      ...ca65wdc,
      ...ca65rockwell,
      ...ca65macpack,
      ...ca65illegal
    )),

    _operand: $ => choice(
      $.immediate_operand,
      $.indexed_indirect_operand,
      $.indirect_indexed_operand,
      $.indirect_operand,
      $.indexed_operand,
      $.address_operand,
      $.accumulator_operand,
      $.literal_operand
    ),

    immediate_operand: $ => $.immediate,

    accumulator_operand: $ => prec(2, $.register),

    literal_operand: $ => prec(2, choice(
      $.string,
      $.char
    )),

    indexed_indirect_operand: $ => seq(
      '(',
      field('address', $.address_expression),
      $.separator,
      field('index', $.register),
      ')'
    ),

    indirect_indexed_operand: $ => seq(
      '(',
      field('address', $.address_expression),
      ')',
      $.separator,
      field('index', $.register)
    ),

    indirect_operand: $ => seq(
      '(',
      $.address_expression,
      ')'
    ),

    indexed_operand: $ => seq(
      field('address', $.address_expression),
      $.separator,
      field('index', $.register)
    ),

    address_operand: $ => $.address_expression,

    address_size_prefix: $ => token(choice('a:', 'f:', 'z:', 'A:', 'F:', 'Z:')),

    _expression: $ => choice(
      $.parenthesized_expression,
      $.call_expression,
      $.scoped_identifier,
      $.unary_expression,
      $.binary_expression,
      $.identifier,
      $.local_identifier,
      $.number,
      $.char
    ),

    parenthesized_expression: $ => seq(
      '(',
      $._expression,
      ')'
    ),

    call_expression: $ => seq(
      field('function', $.directive_name),
      '(',
      field('argument', $._expression),
      ')'
    ),

    scoped_identifier: $ => seq(
      field('scope', choice($.identifier, $.local_identifier)),
      '::',
      field('name', choice($.identifier, $.local_identifier))
    ),

    unary_expression: $ => prec(5, seq(
      field('operator', $.operator),
      field('argument', $._expression)
    )),

    binary_expression: $ => choice(
      ...[
        ['*', 4],
        ['/', 4],
        ['+', 3],
        ['-', 3],
        ['&', 2],
        ['^', 1],
        ['|', 0],
      ].map(([operator, precedence]) =>
        prec.left(precedence, seq(
          field('left', $._expression),
          field('operator', alias(operator, $.operator)),
          field('right', $._expression)
        ))
      )
    ),

    address_expression: $ => choice(
      $.unnamed_label_ref,
      seq(optional($.address_size_prefix), $.base, $.number),
      seq(optional($.address_size_prefix), $.scoped_identifier),
      seq(optional($.address_size_prefix), $._expression),
      prec.left(repeat1(
        choice(
          $.base,
          $.number,
          $.address_size_prefix,
          $.identifier,
          $.local_identifier,
          $.char,
          $.operator,
          $.separator,
          $.register,
          $.bracket
        )
      ))
    ),   

    assignment: $ => choice(
      seq(
        field('name', $.identifier),
        field('operator', $.equal),
        field('value', $.anything)
      ),
      seq(
        field('name', choice($.identifier, $.local_identifier)),
        field('operator', $.assignment_operator),
        field('value', $.address_expression)
      )
    ),

    assignment_operator: $ => token(':='),

    procstart: $ => token(choice('.proc', '.PROC')),
    procend: $ => token(choice('.endproc', '.ENDPROC')),
    proc: $ => seq(
      $.procstart,
      field('name', $.identifier),
      optional(
        seq(
          ':',
          choice('near', 'far', 'huge', 'NEAR', 'FAR', 'HUGE')
        )
      ),
      $._newline,
      repeat(choice($._newline, seq($._block_item, $._newline))),
      $.procend
    ),

    scope_start: $ => seq(token(choice('.scope', '.SCOPE')), field('name', $.identifier)),
    scope_end: $ => token(choice('.endscope', '.ENDSCOPE')),

    struct_start: $ => seq(token(choice('.struct', '.STRUCT')), optional(field('name', $.identifier))),
    struct_end: $ => token(choice('.endstruct', '.ENDSTRUCT')),

    union_start: $ => seq(token(choice('.union', '.UNION')), optional(field('name', $.identifier))),
    union_end: $ => token(choice('.endunion', '.ENDUNION')),

    enum_start: $ => seq(token(choice('.enum', '.ENUM')), optional(field('name', $.identifier))),
    enum_end: $ => token(choice('.endenum', '.ENDENUM')),

    repeat_start: $ => seq(token(choice('.repeat', '.REPEAT')), optional($.directive_arguments)),
    repeat_end: $ => token(choice('.endrep', '.endrepeat', '.ENDREP', '.ENDREPEAT')),

    if_start: $ => seq(
      token(choice(
        '.if', '.IF',
        '.ifdef', '.IFDEF',
        '.ifndef', '.IFNDEF',
        '.ifblank', '.IFBLANK',
        '.ifnblank', '.IFNBLANK'
      )),
      optional($.directive_arguments)
    ),
    elseif_branch: $ => seq(token(choice('.elseif', '.ELSEIF')), optional($.directive_arguments)),
    else_branch: $ => token(choice('.else', '.ELSE')),
    if_end: $ => token(choice('.endif', '.ENDIF')),

    macrostart: $ => token(choice('.macro', '.mac', '.MACRO', '.MAC')),
    macroend: $ => token(choice('.endmacro', '.endmac', '.ENDMACRO', '.ENDMAC')),
    macro: $ => prec(2, seq(
      $.macrostart, 
      field('name', $.identifier),
      optional($.macro_parameters),
      $._newline,
      repeat(choice($._newline, seq($._block_item, $._newline))),
      $.macroend
    )),

    macro_parameters: $ => prec(3, seq(
      field('parameter', $.identifier),
      repeat(seq($.separator, field('parameter', $.identifier)))
    )),

    scope_definition: $ => seq(
      field('start', $.scope_start),
      $._newline,
      repeat(choice($._newline, seq($._block_item, $._newline))),
      field('end', $.scope_end)
    ),

    struct_definition: $ => seq(
      field('start', $.struct_start),
      $._newline,
      repeat(choice($._newline, seq($._block_item, $._newline))),
      field('end', $.struct_end)
    ),

    union_definition: $ => seq(
      field('start', $.union_start),
      $._newline,
      repeat(choice($._newline, seq($._block_item, $._newline))),
      field('end', $.union_end)
    ),

    enum_definition: $ => seq(
      field('start', $.enum_start),
      $._newline,
      repeat(choice($._newline, seq($._block_item, $._newline))),
      field('end', $.enum_end)
    ),

    repeat_block: $ => seq(
      field('start', $.repeat_start),
      $._newline,
      repeat(choice($._newline, seq($._block_item, $._newline))),
      field('end', $.repeat_end)
    ),

    conditional_block: $ => seq(
      field('start', $.if_start),
      $._newline,
      repeat(choice($._newline, seq($._block_item, $._newline))),
      repeat(seq(
        field('branch', choice($.elseif_branch, $.else_branch)),
        $._newline,
        repeat(choice($._newline, seq($._block_item, $._newline)))
      )),
      field('end', $.if_end)
    ),

    directive: $ => seq(
      field('name', $.directive_name),
      optional($.directive_arguments)
    ),

    directive_arguments: $ => repeat1($._directive_argument),

    _directive_argument: $ => choice(
      $.directive_name,
      $.number,
      $.string,
      $.identifier,
      $.base,
      $.operator,
      $.bracket,
      $.separator
    ),

    directive_line: $ => choice(
      $.symbol_directive,
      $.labeled_directive
    ),

    symbol_directive: $ => seq(
      field('name', choice($.identifier, $.local_identifier)),
      field('directive', $.directive_name),
      optional($.directive_arguments)
    ),

    labeled_directive: $ => seq(
      field('label', $.label),
      field('directive', $.directive_name),
      optional($.directive_arguments)
    ),

    generic_line: $ => choice(
      $.macro_call,
      $.enum_member
    ),

    macro_call: $ => seq(
      field('name', choice($.identifier, $.local_identifier)),
      $.argument_list
    ),

    enum_member: $ => seq(
      field('name', choice($.identifier, $.local_identifier))
    ),

    argument_list: $ => repeat1(choice(
      $._argument,
      $.separator
    )),

    grouped_argument: $ => seq(
      '{',
      repeat(choice(
        $.identifier,
        $.local_identifier,
        $.register,
        $.number,
        $.base,
        $.bracket,
        $.separator,
        $.operator,
        $.char,
        $.string
      )),
      '}'
    ),

    _argument: $ => choice(
      $.grouped_argument,
      $.identifier,
      $.local_identifier,
      $.register,
      $.number,
      $.base,
      $.bracket,
      $.operator,
      $.char,
      $.string
    ),

    _preproc: $ => choice(
      $.proc,
      $.macro,
      $.scope_definition,
      $.struct_definition,
      $.union_definition,
      $.enum_definition,
      $.repeat_block,
      $.conditional_block,
      $.directive
    ),

    register: $ => token(
      choice(
        'a', 'x', 'y', 'A', 'X', 'Y'
      )
    ),

    immediate: $ => seq(
      $.immediate_marker,
      choice(
        seq($.base, $.number),
        $._expression
      )
    ),

    base: $ => token(
      choice(
        '$', '%'
      )
    ),

    operator: $ => token(
      choice(...operators)
    ),

    bracket: $ => token(
      choice(...brackets)
    ),

    separator: $ => token(','),

    immediate_marker: $ => token('#'),
    equal: $ => token('='),
    anything: $ => /.+/,
    label: $ => choice(
      prec(1, seq(field('name', choice($.identifier, $.local_identifier)), ':')),
      $.unnamed_label
    ),
    unnamed_label: $ => ':',
    unnamed_label_ref: $ => seq(':', choice(repeat1('+'), repeat1('-'))),
    number: $ => /[0-9a-fA-F]+/,
    local_identifier: $ => /@[a-zA-Z_][a-zA-Z0-9_]*/,
    identifier: $ => /[a-zA-Z_][a-zA-Z0-9_]*/,
    directive_name: $ => /\.[a-zA-Z_][a-zA-Z0-9_]*/,
    comment: $ => /;.*/,
    string: $ => /".*"/,
    char: $ => /\'.\'/,
  }
});

function repeatSep1(rule, sep) {
  return seq(
    rule,
    repeat(seq(sep, rule)),
  );
}

function repeatSep(rule, sep) {
  return optional(repeatSep1(rule, sep));
}
