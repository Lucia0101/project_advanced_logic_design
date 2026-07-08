-- datapath.vhd
-- Top-Level del Data Path per processore RISC-V RV32I

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity datapath is
    Port (
        clk           : in  STD_LOGIC;
        rst           : in  STD_LOGIC;

        -- ===== Interfaccia Memoria Istruzioni =====
        instr_in      : in  STD_LOGIC_VECTOR(31 downto 0);  -- istruzione letta
        pc_addr       : out STD_LOGIC_VECTOR(31 downto 0);  -- indirizzo del PC

        -- ===== Interfaccia Memoria Dati =====
        mem_addr      : out STD_LOGIC_VECTOR(31 downto 0);  -- indirizzo
        mem_wr_data   : out STD_LOGIC_VECTOR(31 downto 0);  -- dato da scrivere
        mem_rd_data   : in  STD_LOGIC_VECTOR(31 downto 0);  -- dato letto
        mem_wr_en     : out STD_LOGIC;                      -- abilita scrittura
        mem_rd_en     : out STD_LOGIC;                      -- abilita lettura

        -- ===== Uscite di Debug (utili per il testbench) =====
        debug_wb_data : out STD_LOGIC_VECTOR(31 downto 0);  -- dato scritto nel reg file
        debug_rd_addr : out STD_LOGIC_VECTOR(4 downto 0);   -- registro destinazione
        debug_reg_wr  : out STD_LOGIC                       -- abilitazione scrittura
    );
end entity datapath;

architecture behavioral of datapath is

    -- ============= COSTANTI OPCODES RISC-V =============
    constant OP_RTYPE  : STD_LOGIC_VECTOR(6 downto 0) := "0110011";
    constant OP_ITYPE  : STD_LOGIC_VECTOR(6 downto 0) := "0010011";
    constant OP_LOAD   : STD_LOGIC_VECTOR(6 downto 0) := "0000011";
    constant OP_STORE  : STD_LOGIC_VECTOR(6 downto 0) := "0100011";
    constant OP_BRANCH : STD_LOGIC_VECTOR(6 downto 0) := "1100011";
    constant OP_JAL    : STD_LOGIC_VECTOR(6 downto 0) := "1101111";
    constant OP_JALR   : STD_LOGIC_VECTOR(6 downto 0) := "1100111";
    constant OP_LUI    : STD_LOGIC_VECTOR(6 downto 0) := "0110111";
    constant OP_AUIPC  : STD_LOGIC_VECTOR(6 downto 0) := "0010111";

    -- ============= SEGNALI INTERNI (i "fili") =============
    -- Decodifica istruzione
    signal opcode     : STD_LOGIC_VECTOR(6 downto 0);
    signal funct3     : STD_LOGIC_VECTOR(2 downto 0);
    signal funct7_5   : STD_LOGIC;
    signal opcode_5   : STD_LOGIC;
    signal rs1_addr   : STD_LOGIC_VECTOR(4 downto 0);
    signal rs2_addr   : STD_LOGIC_VECTOR(4 downto 0);
    signal rd_addr    : STD_LOGIC_VECTOR(4 downto 0);

    -- Program Counter
    signal pc_out     : STD_LOGIC_VECTOR(31 downto 0);
    signal pc_plus4   : STD_LOGIC_VECTOR(31 downto 0);
    signal branch_cond: STD_LOGIC;
    signal pc_load_sig: STD_LOGIC;

    -- Register File
    signal valore_a   : STD_LOGIC_VECTOR(31 downto 0);
    signal valore_b   : STD_LOGIC_VECTOR(31 downto 0);
    signal wb_data    : STD_LOGIC_VECTOR(31 downto 0);

    -- Control Unit
    signal reg_wr     : STD_LOGIC;
    signal alu_src    : STD_LOGIC;
    signal mem_wr_int : STD_LOGIC;
    signal mem_rd_int : STD_LOGIC;
    signal mem_to_reg : STD_LOGIC;
    signal branch     : STD_LOGIC;
    signal jump       : STD_LOGIC;
    signal alu_op     : STD_LOGIC_VECTOR(1 downto 0);

    -- Immediate Extender
    signal tipo_imm   : STD_LOGIC_VECTOR(2 downto 0);
    signal imm_out    : STD_LOGIC_VECTOR(31 downto 0);

    -- ALU e ALU Control
    signal op_sel     : STD_LOGIC_VECTOR(3 downto 0);
    signal alu_a_in   : STD_LOGIC_VECTOR(31 downto 0);
    signal alu_b_in   : STD_LOGIC_VECTOR(31 downto 0);
    signal alu_res    : STD_LOGIC_VECTOR(31 downto 0);
    signal alu_zero   : STD_LOGIC; -- Output inutilizzato della ALU

begin

    -- ============= DECODIFICA ISTRUZIONE (SLICING) =============
    opcode    <= instr_in(6 downto 0);
    opcode_5  <= instr_in(5);
    funct3    <= instr_in(14 downto 12);
    funct7_5  <= instr_in(30);
    rs1_addr  <= instr_in(19 downto 15);
    rs2_addr  <= instr_in(24 downto 20);
    rd_addr   <= instr_in(11 downto 7);

    -- ============= GENERAZIONE TIPO IMM =============
    with opcode select
        tipo_imm <= "000" when OP_ITYPE,
                    "000" when OP_LOAD,
                    "000" when OP_JALR,
                    "001" when OP_STORE,
                    "010" when OP_BRANCH,
                    "011" when OP_LUI,
                    "011" when OP_AUIPC,
                    "100" when OP_JAL,
                    "000" when others;

    -- ============= SEGNALI DI SUPPORTO =============
    -- TODO: Collegare questo segnale alla futura Macchina a Stati (FSM)
    -- Per ora lo teniamo a '1' per consentire il testing
    pc_load_sig <= '1';

    -- ============= ISTANZE DEI MODULI =============

    PC_inst: entity work.program_counter
        port map (
            clk      => clk,
            rst      => rst,
            pc_load  => pc_load_sig,
            pc_src   => branch_cond,  -- Il salto scatta se il Comparator dice '1'
            target   => alu_res,      -- Indirizzo di salto calcolato fisicamente dalla ALU
            pc_out   => pc_out,
            pc_plus4 => pc_plus4
        );

    CU_inst: entity work.control_unit
        port map (
            opcode     => opcode,
            funct3     => funct3,
            funct7_5   => funct7_5,
            reg_wr     => reg_wr,
            alu_src    => alu_src,
            mem_wr     => mem_wr_int,
            mem_rd     => mem_rd_int,
            mem_to_reg => mem_to_reg,
            branch     => branch,
            jump       => jump,
            alu_op     => alu_op
        );

    RF_inst: entity work.register_file
        port map (
            clk       => clk,
            rst       => rst,
            indice_a  => rs1_addr,
            valore_a  => valore_a,
            indice_b  => rs2_addr,
            valore_b  => valore_b,
            wr_en     => reg_wr,
            indice_wr => rd_addr,
            valore_wr => wb_data
        );

    IMM_inst: entity work.imm_extender
        port map (
            istruzione => instr_in,
            tipo_imm   => tipo_imm,
            imm_out    => imm_out
        );

    AC_inst: entity work.alu_control
        port map (
            alu_op   => alu_op,
            funct3   => funct3,
            funct7_5 => funct7_5,
            opcode_5 => opcode_5,
            op_sel   => op_sel
        );

    ALU_inst: entity work.alu
        port map (
            a         => alu_a_in,
            b         => alu_b_in,
            seleziona => op_sel,
            alu_res   => alu_res,
            zero      => alu_zero
        );

    CMP_inst: entity work.comparator
        port map (
            rs1_value   => valore_a,
            rs2_value   => valore_b,
            branch      => branch,
            jump        => jump,
            funct3      => funct3,
            branch_cond => branch_cond
        );

    -- ============= MUX E LOGICA CONCORRENTE =============

    -- MUX ingresso A della ALU:
    -- - Per JAL, BRANCH e AUIPC la ALU deve calcolare (PC + Immediato), quindi in A va il PC.
    -- - Per LUI deve calcolare (0 + Immediato), quindi in A va 0.
    -- - Altrimenti passa normalmente il valore del registro rs1 (es: R-Type, I-Type, JALR).
    alu_a_in <= pc_out          when (opcode = OP_JAL or opcode = OP_BRANCH or opcode = OP_AUIPC) else
                (others => '0') when opcode = OP_LUI else
                valore_a;

    -- MUX ingresso B della ALU:
    -- - Se la Control Unit alza alu_src, OR se siamo in un BRANCH, in B va l'Immediato.
    -- - Altrimenti passa il registro rs2.
    alu_b_in <= imm_out when (alu_src = '1' or opcode = OP_BRANCH) else 
                valore_b;

    -- MUX Write-Back (seleziona cosa scrivere nel Register File)
    wb_data <= mem_rd_data when mem_to_reg = '1' else
               pc_plus4    when jump = '1'       else
               alu_res;

    -- ============= USCITE VERSO L'ESTERNO =============
    pc_addr       <= pc_out;
    mem_addr      <= alu_res;
    mem_wr_data   <= valore_b;
    mem_wr_en     <= mem_wr_int;
    mem_rd_en     <= mem_rd_int;
    
    debug_wb_data <= wb_data;
    debug_rd_addr <= rd_addr;
    debug_reg_wr  <= reg_wr;

end architecture behavioral;