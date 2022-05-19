#include <asm/desc.h>

void my_store_idt(struct desc_ptr *idtr)
{
    asm volatile("sidt %0" :"=m"(*idtr));
}

void my_load_idt(struct desc_ptr *idtr)
{
    asm volatile("lidt %0" ::"m"(*idtr));
}

void my_set_gate_offset(gate_desc *gate, unsigned long addr)
{
    gate->offset_low = addr & 0xFFFF; // masking out bytes after the 16th
    addr = addr >> 16;
    gate->offset_middle = addr & 0xFFFF;
    addr = addr >> 16;
    gate->offset_high = addr;
}

unsigned long my_get_gate_offset(gate_desc *gate)
{
    unsigned long offset = (unsigned long)gate->offset_high << 32;
    offset += (unsigned long)gate->offset_middle << 16;
    offset += (unsigned long)gate->offset_low;
    return offset;
}
