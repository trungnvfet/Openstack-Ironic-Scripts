Suggestions:

#ipxe:

<trungnv> Hi everybody,
  
<trungnv> I have an issue with SAN devices: Could not describe SAN devices: No space left on device (http://ipxe.org/34852006)
  
<trungnv> Anybody help me?
  
<trungnv> This is my logs: http://paste.ubuntu.com/p/vZvqjgcvGS/
  
<nixze> trungnv: the ACPI tables in the machine is full, try to build with DEBBUG=int13 to see more details
  
<AdrianCeleste> I didn't know that could even happen...
  
<trungnv> nixze, DEBBUG=int13? Where is put in?

<nixze> trungnv: make bin/ipxe.pxe DEBUG=int13
  
<trungnv> nixze, if ACPI tables is full then how to change/ modify them?
  
<nixze> trungnv: you probably don't
  
<nixze> what kind of machine is it?

<trungnv> FUJITSU Server PRIMERGY TX2540 M1

<trungnv> I can add 1 volume into machine but with second volume then meet this issue.

<nixze> trungnv: when you run with DEBUG=int13 enables it should show which table it is

<nixze> you can then dump this table in for example linux to have a look on what it contains, and see if there is something that you can 
disable to clean it up

<nixze> it would also be interesting to see this table.

<nixze> I'm of to work for now

<trungnv> nixze, Thanks

===========================================================================================================

<mcb30> trungnv: there's a fixed amount of space within iPXE's .data16 section that gets used for the iBFT (or any other ACPI tables created by iPXE)

<trungnv> mcb30, where is .data16 section?

<mcb30> It's the data portion of iPXE that lives in base memory.  The size of the ACPI table block is controlled by XBFTAB_SIZE in arch/x86/interface/pcbios/int13.c

<mcb30> I'm surprised that you run out of space, though

<mcb30> Do you maybe have multiple network cards on that machine?

<mcb30> Actually, we already filter out NICs that don't provide a route to the iSCSI target, so that shouldn't cause a problem

<trungnv> Yes. I has used two network cards.

<trungnv> on machine, we have three network cards.

<mcb30> Build with DEBUG=int13,ibft and you'll get some output showing what's going in to the constructed table

<mcb30> You can also try increasing XBFTAB_SIZE, but I'd want to see exactly what gets put into your table before making any upstream changes

<trungnv> mcb30, I am using iPXE v1.0.0+. What fixed version of iPXE?

<trungnv> How to change XBFTAB_SIXE?

<trungnv> How to change XBFTAB_SIZE?

<trungnv> mcb30, Should I set DEBUG=int13,ibft of DEBUG=int13?

<mcb30> trungnv: add DEBUG=int13,ibft to your make command line

<mcb30> If you want to try changing XBFTAB_SIZE, edit the #define XBFTAB_SIZE in arch/x86/interface/pcbios/int13.c

<mcb30> Andreas_2Pint: did you get a chance to test the NTLM fix?

<mcb30> http://git.ipxe.org/people/mcb30/ipxe.git/commitdiff/2c23ce0

<mcb30> This is just for NTLM; it doesn't address the client cert issue

<mcb30> Ready to merge to master as soon as you can confirm that it works

<trungnv> mcb30, I was creating new bin/undionly.kpxe with DEBUG=int13,ibft. But very hard to get logs which contained of ACPI table from machine when I test again. I quite very quickly.

<trungnv> I also trying change XBFTAB_SIZE, perhaps I don't see issue no space left.

<Andreas_2Pint> mcb30: Will try to test today, think I can live with the TLS issue, b

<mcb30> trungnv: you can enable CONSOLE_SYSLOG and capture the logs over the network

<trungnv> How to enable it?

<mcb30> trungnv: http://ipxe.org/buildcfg/console_syslog

==========================================================================

<trungnv> Please help me following issues: iBFT error: We expected the control field header.length to have 18 but found 22 instead!

<trungnv> and iBFT error: Control header is invalid!

<trungnv> mcb30, Please help me? I am trying add 3 volumes.

<mcb30> trungnv: what is producing those error messages?

<mcb30> OK, found it

<trungnv> I am trying with TX2540 M1 server along with attaching 3 volumes.

<mcb30> The problem is that the Linux kernel cannot handle more than two NIC or target definitions within the iBFT

<mcb30> It's a kernel bug (or misfeature)

<trungnv> kernel in server of kernel data input?

<mcb30> ???

<mcb30> trungnv: what do you mean?

<trungnv> Is this kernel on OS.  is right?

<mcb30> The kernel that you are loading

<mcb30> The one that you are attempting to boot

<trungnv> ah. Yep. I was trying with ubuntu OS

<trungnv> So I will try with other OS for further testing.

<mcb30> All Linux kernels will have the same problem

<mcb30> Windows may be able to cope with more than 2 targets; I don't know

<trungnv> iBFT only support for two volumes. is right?

<mcb30> iBFT supports an arbitrary number of volumes.  iPXE supports creating an iBFT with an arbitrary number of volumes.  Linux does not support an iBFT that has more than two volumes.

<trungnv> Do you have any links for this information?

<mcb30> https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/drivers/firmware/iscsi_ibft.c#n756

<mcb30> calls ibft_verify_hdr() to verify that the size of the control header is exactly sizeof(struct ibft_control)

<mcb30> which is defined in https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/acpi/actbl1.h#n1567

<mcb30> and, as you can see, includes exactly two NICs and two targets
