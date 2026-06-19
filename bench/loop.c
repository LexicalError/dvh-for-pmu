int main() {
    for (volatile long i = 0; i < 1000000000L; i++) {
        __asm__ volatile("nop");
    }
    return 0;
}