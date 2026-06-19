// ipi_bench.c  — build with a kernel headers tree inside L2
#include <linux/module.h>
#include <linux/smp.h>
#include <linux/ktime.h>
static int n = 10000000;
module_param(n, int, 0);
static void noop(void *x) {}
static int __init m_init(void) {
    int cpu = (smp_processor_id() + 1) % num_online_cpus(), i;
    ktime_t t0 = ktime_get();
    for (i = 0; i < n; i++)
        smp_call_function_single(cpu, noop, NULL, 1);
    pr_info("ipi_bench: %d IPIs to cpu%d in %lld ns (%lld ns/IPI)\n",
            n, cpu, ktime_to_ns(ktime_sub(ktime_get(), t0)),
            ktime_to_ns(ktime_sub(ktime_get(), t0)) / n);
    return -EAGAIN;
}
module_init(m_init);
MODULE_LICENSE("GPL");
