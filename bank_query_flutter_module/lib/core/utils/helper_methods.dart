class HelperMethods {
  static double estimateCharsPerSecond(double speechRate) {
    // Tuned for Google UK Neural voices
    return 10 + (speechRate * 7); // 0.42 → ~13 cps
  }
}