void kernel_main() {
    char* video = (char*)0xB8000;

    const char* msg = "Welcome to MridulOS Kernel in C!";

    for (int i = 0; msg[i] != 0; i++) {
        video[i * 2] = msg[i];
        video[i * 2 + 1] = 0x1F; // white on blue.
    }

    while (1) { }
}