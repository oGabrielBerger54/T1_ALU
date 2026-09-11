// Técnica referente aos packages das aulas de SD!
    package alu_pkg;
    typedef enum logic [2:0] {
        SUM = 3'b000,
        SUB = 3'b001,
        MUL = 3'b010,
        COM = 3'b011,
        AND = 3'b100,
        OR  = 3'b101,
        XOR = 3'b110,
        NOT = 3'b111
    } op_code;
    endpackage
