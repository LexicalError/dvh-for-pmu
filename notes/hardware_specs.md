# Hardware Specs

## PMU Machine

```bash
lscpu
Architecture:                x86_64
  CPU op-mode(s):            32-bit, 64-bit
  Address sizes:             39 bits physical, 48 bits virtual
  Byte Order:                Little Endian
CPU(s):                      8
  On-line CPU(s) list:       0-7
Vendor ID:                   GenuineIntel
  Model name:                Intel(R) Core(TM) i7-7700HQ CPU @ 2.80GHz
    CPU family:              6
    Model:                   158
    Thread(s) per core:      2
    Core(s) per socket:      4
    Socket(s):               1
    Stepping:                9
    CPU(s) scaling MHz:      25%
    CPU max MHz:             3800.0000
    CPU min MHz:             800.0000
    BogoMIPS:                5599.85
    Flags:                   fpu vme de pse tsc msr pae mce cx8 apic sep m
                             trr pge mca cmov pat pse36 clflush dts acpi m
                             mx fxsr sse sse2 ss ht tm pbe syscall nx pdpe
                             1gb rdtscp lm constant_tsc art arch_perfmon p
                             ebs bts rep_good nopl xtopology nonstop_tsc c
                             puid aperfmperf pni pclmulqdq dtes64 monitor 
                             ds_cpl vmx est tm2 ssse3 sdbg fma cx16 xtpr p
                             dcm pcid sse4_1 sse4_2 x2apic movbe popcnt ts
                             c_deadline_timer aes xsave avx f16c rdrand la
                             hf_lm abm 3dnowprefetch cpuid_fault epb pti s
                             sbd ibrs ibpb stibp tpr_shadow flexpriority e
                             pt vpid ept_ad fsgsbase tsc_adjust sgx bmi1 a
                             vx2 smep bmi2 erms invpcid mpx rdseed adx sma
                             p clflushopt intel_pt xsaveopt xsavec xgetbv1
                              xsaves dtherm ida arat pln pts hwp hwp_notif
                             y hwp_act_window hwp_epp vnmi md_clear flush_
                             l1d arch_capabilities
Virtualization features:     
  Virtualization:            VT-x
Caches (sum of all):         
  L1d:                       128 KiB (4 instances)
  L1i:                       128 KiB (4 instances)
  L2:                        1 MiB (4 instances)
  L3:                        6 MiB (1 instance)
NUMA:                        
  NUMA node(s):              1
  NUMA node0 CPU(s):         0-7
Vulnerabilities:             
  Gather data sampling:      Mitigation; Microcode
  Ghostwrite:                Not affected
  Indirect target selection: Not affected
  Itlb multihit:             KVM: Mitigation: Split huge pages
  L1tf:                      Mitigation; PTE Inversion; VMX conditional ca
                             che flushes, SMT vulnerable
  Mds:                       Mitigation; Clear CPU buffers; SMT vulnerable
  Meltdown:                  Mitigation; PTI
  Mmio stale data:           Mitigation; Clear CPU buffers; SMT vulnerable
  Old microcode:             Not affected
  Reg file data sampling:    Not affected
  Retbleed:                  Mitigation; IBRS
  Spec rstack overflow:      Not affected
  Spec store bypass:         Mitigation; Speculative Store Bypass disabled
                              via prctl
  Spectre v1:                Mitigation; usercopy/swapgs barriers and __us
                             er pointer sanitization
  Spectre v2:                Mitigation; IBRS; IBPB conditional; STIBP con
                             ditional; RSB filling; PBRSB-eIBRS Not affect
                             ed; BHI Not affected
  Srbds:                     Mitigation; Microcode
  Tsa:                       Not affected
  Tsx async abort:           Not affected
  Vmscape:                   Mitigation; IBPB before exit to userspace

free -h
               total        used        free      shared  buff/cache   available
Mem:            15Gi       1.8Gi        12Gi       1.3Mi       1.8Gi        13Gi
Swap:           15Gi          0B        15Gi
```

## IPI machine
```
Architecture:                x86_64
  CPU op-mode(s):            32-bit, 64-bit
  Address sizes:             46 bits physical, 48 bits virtual
  Byte Order:                Little Endian
CPU(s):                      20
  On-line CPU(s) list:       0-19
Vendor ID:                   GenuineIntel
  Model name:                13th Gen Intel(R) Core(TM) i5-13600K
    CPU family:              6
    Model:                   183
    Thread(s) per core:      2
    Core(s) per socket:      14
    Socket(s):               1
    Stepping:                1
    Microcode version:       0x133
    CPU(s) scaling MHz:      27%
    CPU max MHz:             5100.0000
    CPU min MHz:             800.0000
    BogoMIPS:                6988.80
    Flags:                   fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe syscall nx pdpe1gb rdtscp lm constant_tsc art arch_perfmon pebs bts rep_good no
                             pl xtopology nonstop_tsc cpuid aperfmperf tsc_known_freq pni pclmulqdq dtes64 monitor ds_cpl vmx smx est tm2 ssse3 sdbg fma cx16 xtpr pdcm pcid sse4_1 sse4_2 x2apic movbe popcnt tsc_deadline_timer ae
                             s xsave avx f16c rdrand lahf_lm abm 3dnowprefetch cpuid_fault ssbd ibrs ibpb stibp ibrs_enhanced tpr_shadow flexpriority ept vpid ept_ad fsgsbase tsc_adjust bmi1 avx2 smep bmi2 erms invpcid rdseed ad
                             x smap clflushopt clwb intel_pt sha_ni xsaveopt xsavec xgetbv1 xsaves split_lock_detect user_shstk avx_vnni dtherm ida arat pln pts hwp hwp_notify hwp_act_window hwp_epp hwp_pkg_req hfi vnmi umip pku
                              ospke waitpkg gfni vaes vpclmulqdq rdpid movdiri movdir64b fsrm md_clear serialize pconfig arch_lbr ibt flush_l1d arch_capabilities
Virtualization features:     
  Virtualization:            VT-x
Caches (sum of all):         
  L1d:                       544 KiB (14 instances)
  L1i:                       704 KiB (14 instances)
  L2:                        20 MiB (8 instances)
  L3:                        24 MiB (1 instance)
NUMA:                        
  NUMA node(s):              1
  NUMA node0 CPU(s):         0-19
Vulnerabilities:             
  Gather data sampling:      Not affected
  Ghostwrite:                Not affected
  Indirect target selection: Not affected
  Itlb multihit:             Not affected
  L1tf:                      Not affected
  Mds:                       Not affected
  Meltdown:                  Not affected
  Mmio stale data:           Not affected
  Old microcode:             Not affected
  Reg file data sampling:    Mitigation; Clear Register File
  Retbleed:                  Not affected
  Spec rstack overflow:      Not affected
  Spec store bypass:         Mitigation; Speculative Store Bypass disabled via prctl
  Spectre v1:                Mitigation; usercopy/swapgs barriers and __user pointer sanitization
  Spectre v2:                Mitigation; Enhanced / Automatic IBRS; IBPB conditional; PBRSB-eIBRS SW sequence; BHI BHI_DIS_S
  Srbds:                     Not affected
  Tsa:                       Not affected
  Tsx async abort:           Not affected
  Vmscape:                   Mitigation; IBPB before exit to userspace
```
