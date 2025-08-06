mixin MixinsUtils {
  String? isEmpty(String? value, [String? menssage]) {
    if (!(value!.isNotEmpty)) {
      return menssage ?? 'Por favor, insira valor válida';
    }
    return null;
  }

  String? matchPassword(
    String? valueOne,
    String? valueTwo, [
    String? menssage,
  ]) {
    if (valueOne != null && valueTwo != null) {
      if (valueOne != valueTwo || valueOne.isEmpty || valueTwo.isEmpty) {
        return menssage ?? 'As senhas não coincidem';
      }
    }

    return null;
  }

  String? moreThanFive(String? value, [String? mensagem]) {
    if ((value?.length ?? 0) < 6) {
      return mensagem ?? 'O código tem no mínimo 6 caracteres';
    }
    return null;
  }

  String? moreThanSeven(String? value, [String? menssage]) {
    if ((value?.length ?? 0) < 8) {
      return menssage ?? 'A senha deve ter no mínimo 8 caracteres';
    }
    return null;
  }
  

  String? hasNumber(String value, [String? menssage]) {
    if (!RegExp(r'\d').hasMatch(value)) {
      return menssage ?? 'A senha deve ter no mínimo 1 número';
    }
    return null;
  }

  String? upperLetter(String value, [String? menssage]) {
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return menssage ?? 'A senha deve ter no mínimo 1 letra maiúscula';
    }
    return null;
  }

  String? lowerLetter(String value, [String? menssage]) {
    if (!RegExp(r'[a-z]').hasMatch(value)) {
      return menssage ?? 'A senha deve ter no mínimo 1 letra minúscula';
    }
    return null;
  }

  String? validateEmail(String? value, [String? menssage]) {
    final emailRegExp = RegExp(
      r'^[a-zA-Z0-9._-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegExp.hasMatch(value!.trim())) {
      return menssage ?? 'Por favor, insira um e-mail válido';
    }
    return null;
  }

  String? validateTelephone(String? value, [String? menssage]) {
    String phone = (value ?? '').replaceAll(RegExp(r'[^0-9]'), '');

    if (!RegExp(r'^\d{11}$').hasMatch(phone)) {
      return menssage ?? 'Por favor, insira um telefone válido';
    }
    return null;
  }

  String? combine(List<String? Function()> validatores) {
    for (final func in validatores) {
      final validation = func();
      if (validation != null) return validation;
    }
    return null;
  }

  String? validateCPF(String? value, [String? menssage]) {
    if (value == null || value.isEmpty) {
      return menssage ?? 'Por favor, insira um CPF válido';
    } else {
      value = value.replaceAll('.', '');
      value = value.replaceAll('-', '');
    }

    if (value.length != 11) {
      return 'O CPF deve ter 11 dígitos';
    }

    return null;
  }

  String? validateDate(String? value, [String? menssage]) {
    RegExp regExp = RegExp(
      r'^(?:(?:31(\/|-|\.)(?:0?[13578]|1[02]))\1|(?:(?:29|30)(\/|-|\.)(?:0?[13-9]|1[0-2])\2))(?:(?:1[6-9]|[2-9]\d)?\d{2})$|^(?:29(\/|-|\.)0?2\3(?:(?:(?:1[6-9]|[2-9]\d)?(?:0[48]|[2468][048]|[13579][26])|(?:(?:16|[2468][048]|[3579][26])00))))$|^(?:0?[1-9]|1\d|2[0-8])(\/|-|\.)(?:(?:0?[1-9])|(?:1[0-2]))\4(?:(?:1[6-9]|[2-9]\d)?\d{2})$',
    );

    if (value == null || value.isEmpty || !regExp.hasMatch(value)) {
      return menssage ?? 'Por favor, insira uma data válida';
    }

    if (value.replaceAll('/', '').length != 8) {
      return menssage ?? 'A data deve ter 8 dígitos';
    }

    return null;
  }
}
