/// Extensões para a classe String
extension StringExtension on String {
  /// Capitaliza a primeira letra de cada palavra na string
  String capitalize() {
    if (isEmpty) return this;
    return split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }
  
  /// Capitaliza apenas a primeira letra da string
  String capitalizeFirst() {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1);
  }
  
  /// Formata tópicos removendo underlines e capitalizando
  /// Exemplo: "problema_emocional" -> "Problema Emocional"
  String get formatTopicName {
    if (isEmpty) return this;
    return replaceAll('_', ' ')
        .split(' ')
        .map((word) => word.isNotEmpty 
            ? '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}'
            : word)
        .join(' ');
  }
}
