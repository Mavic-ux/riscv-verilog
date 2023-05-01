#include <elfio/elfio.hpp>

#include <verilated_vcd_c.h>

#include "Vtop.h"
#include "Vtop_top.h"
#include "Vtop_instrmem__P12.h"

#include <iostream>
#include <stdlib.h>


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
    uint32_t address = segment->get_virtual_address();

    size_t filesz = static_cast<size_t>(segment->get_file_size());
    size_t memsz = static_cast<size_t>(segment->get_memory_size());

    if (filesz) {
      const auto *begin =
          reinterpret_cast<const uint8_t *>(segment->get_data());
      uint8_t *dst =
          reinterpret_cast<uint8_t *>(top_module->top->instrmem->buffer);
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