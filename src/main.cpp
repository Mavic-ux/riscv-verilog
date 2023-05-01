#include <elfio/elfio.hpp>

#include <verilated_vcd_c.h>

#include "Vtop.h"
// #include "Vtop___024root.h"
// #include "Vtop__Dpi.h"
// #include "Vtop__Syms.h"
#include "Vtop_regfile.h"
#include "Vtop_imem.h"
#include "Vtop_top.h"
#include "Vtop_cpu.h"


#include <array>
#include <iostream>
#include <stdlib.h>

// void RegfileStr(const uint32_t *registers) {
//   std::cout << std::setfill('0');
//   constexpr std::size_t lineNum = 8;

//   for (std::size_t i = 0; i < lineNum; ++i) {
//     for (std::size_t j = 0; j < 32 / lineNum; ++j) {
//       auto regIdx = j * lineNum + i;
//       auto &reg = registers[regIdx];
//       std::cout << "  [" << std::dec << std::setw(2) << regIdx << "] ";
//       std::cout << "0x" << std::hex << std::setw(sizeof(reg) * 2) << reg;
//     }
//     std::cout << std::endl;
//   }
// }

int main(int argc, char **argv) {
  Verilated::commandArgs(argc, argv);
  auto top_module = std::make_unique<Vtop>();

  Verilated::traceEverOn(true);
  auto vcd = std::make_unique<VerilatedVcdC>();
  top_module->trace(vcd.get(), 10); 
  vcd->open("dump.vcd");     

  ELFIO::elfio m_reader{};
  m_reader.load(argv[1]);

  ELFIO::Elf_Half seg_num = m_reader.segments.size();
  
  for (size_t seg_i = 0; seg_i < seg_num; ++seg_i) {
    const ELFIO::segment *segment = m_reader.segments[seg_i];
    if (segment->get_type() != ELFIO::PT_LOAD) {
      continue;
    }
    uint32_t address = segment->get_virtual_address();

    size_t filesz = static_cast<size_t>(segment->get_file_size());
    size_t memsz = static_cast<size_t>(segment->get_memory_size());

    if (filesz) {
      const auto *begin =
          reinterpret_cast<const uint8_t *>(segment->get_data());
      uint8_t *dst =
          reinterpret_cast<uint8_t *>(top_module->top->imem->RAM);
      std::copy(begin, begin + filesz, dst + address);
    }
  }

  top_module->top->pc = m_reader.get_entry();

  
  vluint64_t vtime = 0;
  int clock = 0;
  top_module->clk = 0;
  while (!Verilated::gotFinish()) {
    
    vtime += 1;
    if (vtime % 8 == 0)
      clock ^= 1;

    top_module->clk = clock;
    top_module->eval();
    vcd->dump(vtime);
  }

  top_module->final();
  if (vcd)
    vcd->close();
  exit(EXIT_SUCCESS);
}