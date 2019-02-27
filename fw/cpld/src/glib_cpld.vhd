--=================================================================================================--
--==================================== Module Information =========================================--
--=================================================================================================--
--                                                                                              
-- Company:             CERN (PH-ESE-BE)                                                        
-- Engineer:            Paschalis Vichoudis                                                     
--                      Manoel Barros Marin (manoel.barros.marin@cern.ch) (m.barros.marin@ieee.org)   
--                                                                                              
-- Create Date:         04/07/2013                                                              
-- Project Name:        GLIB Project                                                            
-- Module Name:         GLIB CPLD firmware                                                      
--                                                                                              
-- Language:            VHDL'93                                                                 
--                                                                                              
-- Target Devices:      GLIB (XC2C128 CoolRunner-II)                                            
-- Tool versions:       ISE 14.5                                                                
--                                                                                              
-- Revision:            2.0                                                                        
--                                                                                              
-- Additional Comments:                                                                         
--                                                                                              
--=================================================================================================--
--=================================================================================================--

-- IEEE VHDL standard library:
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Xilinx devices library:
library unisim;
use unisim.vcomponents.all;

--=================================================================================================--
--======================================= Module Body =============================================-- 
--=================================================================================================--

entity glib_cpld is
   port (   
   
      xtal_cpld                     : inout std_logic;  
      ------------------------------
      pgood_2v5                     : in    std_logic;  
      pgood_3v3                     : in    std_logic;  
      pgood_1v0                     : in    std_logic;  
      pgood_1v5                     : in    std_logic;  
      ------------------------------
      v6_cpld                       : inout std_logic_vector(5 downto 0);     
      ------------------------------
      fpga_reset_b                  : inout std_logic;  
      fpga_done                     : inout std_logic;  
      fpga_init_b                   : inout std_logic;  
      fpga_program_b                : inout std_logic;  
      ------------------------------
      sw                            : inout std_logic_vector(1 to 4);  
      ------------------------------
      cpld_led                      : inout std_logic_vector(1 to 3);     
      ------------------------------
      cpld_rs_in                    : in    std_logic_vector(0 to 1);
      cpld_a22_in                   : in    std_logic;
      cpld_a21_in                   : in    std_logic;   
      cpld_a22_out                  : out   std_logic;
      cpld_a21_out                  : out   std_logic;
      ------------------------------
      fmcx_pg_c2m                   : inout std_logic;  
      fmc_pg_m2c                    : inout std_logic_vector(1 to 2);  
      fmc_prsnt_m2c_l               : inout std_logic_vector(1 to 2);  
      ------------------------------ 
      mmc_low_voltage_pok           : inout std_logic;  
      mmc_fpga1_init_done           : inout std_logic;  
      mmc_fpga2_init_done           : inout std_logic;  
      mmc_reset_fpga_n              : inout std_logic;  
      mmc_reload_fpgas_n            : inout std_logic;  
      mmc_pg4                       : inout std_logic;  
      mmc_pe6                       : inout std_logic;  
      rtm_i2c_en                    : inout std_logic; -- MMC code to be modified for SPI 
      rtm_3v3_en                    : inout std_logic; -- MMC code to be modified for SPI  
      rtm_12v_en                    : inout std_logic; -- MMC code to be modified for SPI                      
      rtm_ps                        : inout std_logic; -- MMC code to be modified for SPI  
      ------------------------------
      mmc_tdi                       : in    std_logic;  
      mmc_tdo                       : in    std_logic;  
      mmc_tms                       : in    std_logic;  
      mmc_tck                       : in    std_logic;
      ------------------------------
      amc_tck                       : inout std_logic;  
      amc_tms                       : inout std_logic;  
      amc_tdo                       : inout std_logic;  
      amc_tdi                       : inout std_logic;  
      ------------------------------ 
      gbe_tdo                       : inout std_logic;  
      gbe_tck                       : inout std_logic;  
      gbe_tdi                       : inout std_logic;  
      gbe_tms                       : inout std_logic;  
      ------------------------------ 
      fmc1_tms                      : inout std_logic;  
      fmc1_tdi                      : inout std_logic;  
      fmc1_tck                      : inout std_logic;  
      fmc1_tdo                      : inout std_logic;  
      ------------------------------ 
      fmc2_tdo                      : inout std_logic;  
      fmc2_tck                      : inout std_logic;  
      fmc2_tdi                      : inout std_logic;  
      fmc2_tms                      : inout std_logic;  
      ------------------------------ 
      sram1_tdo                     : inout std_logic;  
      sram1_tck                     : inout std_logic;  
      sram1_tms                     : inout std_logic;  
      sram1_tdi                     : inout std_logic;  
      ------------------------------ 
      sram2_tdo                     : inout std_logic;  
      sram2_tck                     : inout std_logic;  
      sram2_tms                     : inout std_logic;  
      sram2_tdi                     : inout std_logic;  
      ------------------------------
      fpga_tms                      : out   std_logic;  
      fpga_tck                      : out   std_logic;  
      fpga_tdi                      : out   std_logic;  
      fpga_tdo                      : in    std_logic;  
      ------------------------------ 
      jtag_header_tdi               : out   std_logic;  
      jtag_header_tdo               : in    std_logic;  
      jtag_header_tck               : in    std_logic;  
      jtag_header_tms               : in    std_logic
   
   );                                
end glib_cpld;                      
architecture behavioral of glib_cpld is  

   --============================ Declarations ===========================--
   
   --==============--
   -- Clock scheme --
   --==============-- 
   
   signal clk                       : std_logic;
   
   --=============--
   -- I/O mapping --
   --=============--    
   
   signal amc_slot                  : std_logic_vector(3 downto 0);
   signal i2c_bridge_en             : std_logic;
   
   --============--
   -- Power good --
   --============--    
   
   signal ltm_pgood                 : std_logic;
   signal glib_pgood                : std_logic;
   signal fmc_pbad                  : std_logic;
   signal fmc_c2m_pg                : std_logic;   
   signal mmc_pok                   : std_logic;    
   
   --====================--
   -- FPGA configuration --
   --====================--
   
   signal a22_pull                  : std_logic;
   signal mux_sel                   : std_logic;
   signal fpga_init_b_r             : std_logic;
   signal fpga_program_b_trigger    : std_logic;
   signal fdce_clr                  : std_logic;
   signal fpga_done_latch           : std_logic;
   signal error_check_enable        : std_logic;
   signal configuration_error       : std_logic;
   signal configuration_error_latch : std_logic;

   --=====================================================================--

--========================================================================--
-----        --===================================================--
begin      --================== Architecture Body ==================-- 
-----        --===================================================--
--========================================================================--

   --============================ User Logic =============================--
   
   --==============--
   -- Clock scheme --
   --==============-- 
   
   mclk_buf: bufg port map (i => xtal_cpld, o => clk);  
   
   --=============--
   -- I/O mapping --
   --=============--  

   -- MMC <-> CPLD:
   --==============

-- mmc_fpga1_init_done            <= 'Z';      
-- mmc_fpga2_init_done            <= 'Z';        
-- mmc_reset_fpga_n               <= 'Z';                 
-- mmc_reload_fpgas_n             <= 'Z';
-- mmc_pg4                        <= 'Z'; -- Actually it is mmc_pe7                       
-- mmc_pe6                        <= 'Z'; -- Currently, the only user defined pin available	
-- rtm_i2c_en	                   <= 'Z';  					
-- rtm_3v3_en                     <= 'Z'; 					        
-- rtm_12v_en                     <= 'Z'; 					                          
-- rtm_ps 		                   <= 'Z'; 					        
           
   
   -- Note!!! RTM is no used by GLIB.
   --         Instead, "rtm_i2c_en", "rtm_3v3_en", "rtm_12v_en" and "rtm_ps" are used as a bus for slot assignment.   
   amc_slot                         <= rtm_i2c_en & rtm_3v3_en & rtm_12v_en & rtm_ps; 
   --i2c_bridge_en                  <= mmc_pg4;  -- drives the i2c bridge enable, no need to read its state

   
   -- FPGA <-> CPLD:       
   --===============
   
   -- v6_cpld(4)                    <= --unused
   v6_cpld(3 downto 0)              <= amc_slot when glib_pgood = '1' else (others => 'Z');
            
   -- LEDs:            
   --======       
            
   cpld_led(3)                      <= '1'   when glib_pgood = '1' else 'Z';  -- Power good   
   cpld_led(2)                      <= sw(2) when glib_pgood = '1' else 'Z';  -- JTAG chain mode
   cpld_led(1)                      <= sw(1) when glib_pgood = '1' else 'Z';  -- FLASH mode
   
   --================--
   -- SW multiplexor --
   --================--   

   --------------
   sw_mux: process(sw)
   --------------
   begin
   
      -- JTAG Chain:
      --============ 
      
      case sw(1) is
         -----------                --====== Boundary Scan test ======--
         when '1' =>                -- Master: jtag connector, Chain: fpga->sram1->sram2->phy   
         -----------
            if glib_pgood='1' then
               fpga_tck             <= jtag_header_tck; 
               sram1_tck            <= jtag_header_tck; 
               sram2_tck            <= jtag_header_tck; 
               gbe_tck              <= jtag_header_tck; 
               --      
               fpga_tms             <= jtag_header_tms; 
               sram1_tms            <= jtag_header_tms; 
               sram2_tms            <= jtag_header_tms; 
               gbe_tms              <= jtag_header_tms; 
               -- 
               jtag_header_tdi      <= gbe_tdo; 
                                       gbe_tdi <= sram2_tdo; 
                                                   sram2_tdi <= sram1_tdo; 
                                                               sram1_tdi <= fpga_tdo;
                                                                           fpga_tdi <= jtag_header_tdo;         
            else            
               fpga_tck             <= 'Z'; 
               sram1_tck            <= 'Z'; 
               sram2_tck            <= 'Z'; 
               gbe_tck              <= 'Z'; 
               --       
               fpga_tms             <= 'Z'; 
               sram1_tms            <= 'Z'; 
               sram2_tms            <= 'Z'; 
               gbe_tms              <= 'Z';          
               --         
               fpga_tdi             <= 'Z';
               sram1_tdi            <= 'Z';
               sram2_tdi            <= 'Z';
               gbe_tdi              <= 'Z';
               jtag_header_tdi      <= 'Z';            
            end if;
         --------------             --====== Standard ===================--
         when others =>             -- Master: jtag connector, Chain: fpga
         --------------
            sram1_tck               <= 'Z'; 
            sram2_tck               <= 'Z'; 
            gbe_tck                 <= 'Z'; 
            --
            sram1_tms               <= 'Z'; 
            sram2_tms               <= 'Z'; 
            gbe_tms                 <= 'Z'; 
            --
            sram1_tdi               <= 'Z';
            sram2_tdi               <= 'Z';
            gbe_tdi                 <= 'Z';
            if glib_pgood = '1' then
               fpga_tck             <= jtag_header_tck; 
               fpga_tms             <= jtag_header_tms; 
               --          
               jtag_header_tdi      <= fpga_tdo;
                                       fpga_tdi <= jtag_header_tdo;         
            else 
               fpga_tck             <= 'Z'; 
               fpga_tms             <= 'Z'; 
               --            
               fpga_tdi             <= 'Z';
               jtag_header_tdi      <= 'Z';
            end if;
      end case;   

      -- FLASH A23 pin pulling:
      --=======================
      
      case sw(2) is
         -----------   
         when '1' =>    
         -----------
            a22_pull                <= '1';
         --------------            
         when others =>             
         -------------- 
            a22_pull                <= '0';
      end case;  
   
   end process;   
   
   --============--
   -- Power good --
   --============--      
   
   -- Logic:
   --=======
   
   ltm_pgood                        <= pgood_1v0 and pgood_1v5 and pgood_2v5 and pgood_3v3;
                                    
   fmc_pbad                         <= '1' when    (fmc_prsnt_m2c_l(1) = '0' and fmc_pg_m2c(1) = '0')  
                                                or (fmc_prsnt_m2c_l(2) = '0' and fmc_pg_m2c(2) = '0')
                                           else
                                       '0';                              
         
   -- Signals:       
   --=========       
         
   fmc_c2m_pg                       <= ltm_pgood;
                     
   glib_pgood                       <= ltm_pgood  and (not fmc_pbad);                         
                     
   mmc_pok                          <= glib_pgood;
                     
   -- Outputs:                   
   --=========                   
                     
   fmcx_pg_c2m                      <= fmc_c2m_pg;
                           
   mmc_low_voltage_pok              <= mmc_pok; 

   --====================--
   -- FPGA configuration --
   --====================--

   fdce_clr <= (not ltm_pgood) or (not fpga_program_b_trigger);      

   -- Configuration error handling:
   --==============================
   
   main:process(clk)   
      constant FPGA_PROGRAM_B_DLY   : integer := 40 - 1;
      constant MAX_DLY              : integer := (2**16) - 1;
      type     state_T              is (e0_idle, e1_start);
      variable state                : state_T := e0_idle;
      variable timer1               : integer range 0 to FPGA_PROGRAM_B_DLY;
      variable timer2               : integer range 0 to MAX_DLY;
   begin
      if rising_edge(clk) then     
         -- Registers:  
         fpga_init_b_r              <= fpga_init_b;     
         fpga_program_b_trigger     <= v6_cpld(5);
         -- fpga_program_b control fsm:           
         case state is
            when e0_idle =>            
               fpga_program_b       <= 'Z';           
               if fpga_program_b_trigger = '0' then
                  state             := e1_start;
               end if;
            when e1_start =>            
               fpga_program_b       <= '0';
               if timer1 = FPGA_PROGRAM_B_DLY then
                  state             := e0_idle;
                  timer1            := 0;
               else  
                  timer1            := timer1 + 1;
               end if;
         end case;       
         -- Configuration error check delay:
         if ltm_pgood = '1' and fpga_program_b_trigger = '1' then
            if timer2 = MAX_DLY then
               error_check_enable   <= '1';  
            else           
               timer2               := timer2 + 1;                            
            end if;  
         else  
            fpga_init_b_r           <= '0';
            -- 
            timer2                  := 0;         
            error_check_enable      <= '0';          
         end if;      
      end if;
   end process;

   configuration_error              <= '1' when     error_check_enable = '1'              
                                                and fpga_program_b     = '1'                      
                                                and (fpga_init_b_r = '1' and fpga_init_b = '0') -- Falling edge detector:
                                           else '0';

   config_err_fdce: FDCE
      generic map (     
         INIT                       => '0')  
      port map (                    
         Q                          => configuration_error_latch,    
         C                          => configuration_error,
         CE                         => '1',        
         CLR                        => fdce_clr,      
         D                          => '1'         
      );   

   -- Configuration done handling:
   --=============================

   fpga_done_fdce: FDCE
      generic map (     
         INIT                       => '0')  
      port map (                    
         Q                          => fpga_done_latch,    
         C                          => fpga_done,
         CE                         => '1',        
         CLR                        => fdce_clr,      
         D                          => '1'         
      );

   -- RS pins multiplexor selector control:
   --======================================
   
   mux_sel                          <= '1' when fpga_done_latch = '1' or configuration_error_latch = '1'
                                       else '0';

   -- FLASH address pins assignment:
   --===============================
            
   cpld_a22_out                     <= 'Z'         when glib_pgood = '0' else
                                       cpld_a22_in when mux_sel = '1'    else 
                                       a22_pull;   
            
   cpld_a21_out                     <= 'Z'         when glib_pgood = '0' else
                                       cpld_a21_in;

   --=====================================================================--
end behavioral;
--=================================================================================================--
--=================================================================================================--                       