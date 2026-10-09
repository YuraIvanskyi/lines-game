/// Occupancy mask. Words are 32-bit so the same code runs on the VM and on the web.
class BitGrid {
  BitGrid._(this.length, this.words);

  final int length;
  final List<int> words;

  factory BitGrid.empty(int length) {
    return BitGrid._(length, List<int>.filled((length + 31) >> 5, 0));
  }

  factory BitGrid.of(int length, Iterable<int> setBits) {
    final grid = BitGrid.empty(length);
    for (final index in setBits) {
      grid._setMutable(index);
    }
    return grid;
  }

  bool test(int index) {
    if (index < 0 || index >= length) return false;
    return (words[index >> 5] & (1 << (index & 31))) != 0;
  }

  BitGrid set(int index) {
    final copy = List<int>.of(words);
    copy[index >> 5] |= 1 << (index & 31);
    return BitGrid._(length, copy);
  }

  void _setMutable(int index) {
    words[index >> 5] |= 1 << (index & 31);
  }

  @override
  bool operator ==(Object other) {
    if (other is! BitGrid || other.length != length || other.words.length != words.length) {
      return false;
    }
    for (var i = 0; i < words.length; i++) {
      if (words[i] != other.words[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hash(length, Object.hashAll(words));
}
