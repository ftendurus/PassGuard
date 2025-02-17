import 'package:passguard/provider/generatedPasswordProvider.dart';
import 'package:passguard/widgets/customButton.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class GeneratorPage extends StatelessWidget {
  const GeneratorPage({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Sifre uretici',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: size.width * 0.04,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Material(
                  color: Theme.of(context).highlightColor,
                  borderRadius: BorderRadius.circular(5),
                  child: Column(
                    children: [
                      Center(
                        heightFactor: 2.5,
                        child: Text(
                          context
                              .watch<GeneratedPasswordProvider>()
                              .generatedpassword,
                          style: const TextStyle(
                            fontSize: 24,
                          ),
                        ),
                      ),
                      LinearProgressIndicator(
                        value: context
                            .watch<GeneratedPasswordProvider>()
                            .passwordstrength,
                        backgroundColor: Colors.grey[300],
                        color: context
                                    .watch<GeneratedPasswordProvider>()
                                    .passwordstrength <=
                                1.6 / 4
                            ? Colors.red
                            : context
                                        .watch<GeneratedPasswordProvider>()
                                        .passwordstrength <=
                                    3.4 / 4
                                ? Colors.yellow
                                : Colors.green,
                        minHeight: 4,
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: size.height * 0.02,
                ),
                CustomButton(
                    ontap: () {
                      context
                          .read<GeneratedPasswordProvider>()
                          .generatePassword;
                    },
                    buttontext: context
                            .watch<GeneratedPasswordProvider>()
                            .generatedpassword
                            .isEmpty
                        ? 'Sifre olustur'
                        : 'Yeniden sifre olustur'),
                SizedBox(
                  height: size.height * 0.01,
                ),
                InkWell(
                  onTap: context
                          .watch<GeneratedPasswordProvider>()
                          .generatedpassword
                          .isEmpty
                      ? () => ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Lutfen sifre olusturun'),
                            ),
                          )
                      : () {
                          Clipboard.setData(
                            ClipboardData(
                              text: context
                                  .read<GeneratedPasswordProvider>()
                                  .generatedpassword,
                            ),
                          ).then(
                            (value) {
                              return ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Sifre cihaza kopyalandi'),
                                ),
                              );
                            },
                          );
                        },
                  borderRadius: BorderRadius.circular(5),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        width: 1,
                        color: Colors.grey,
                      ),
                      borderRadius: BorderRadius.circular(5),
                      color: Theme.of(context).highlightColor,
                    ),
                    child: const Center(
                      heightFactor: 3,
                      child: Text('Sifreyi kopyala',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                          )),
                    ),
                  ),
                ),
                SizedBox(
                  height: size.height * 0.02,
                ),
                Text(
                  'Secenekler',
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                _buildSiderOption(
                  titletext: 'Uzunluk',
                  hinttext: context
                      .watch<GeneratedPasswordProvider>()
                      .length
                      .floor()
                      .toString(),
                  onchanged: (value) {
                    context.read<GeneratedPasswordProvider>().length = value;
                  },
                  value: context.watch<GeneratedPasswordProvider>().length,
                ),
                _buildSwitchOption(
                  value:
                      context.watch<GeneratedPasswordProvider>().uppercaseatoz,
                  onchanged: (value) {
                    context.read<GeneratedPasswordProvider>().uppercaseatoz =
                        value;
                  },
                  hinttext: 'Buyuk karakterler ( A - Z )',
                  titletext: 'A-Z',
                ),
                _buildSwitchOption(
                  value:
                      context.watch<GeneratedPasswordProvider>().lowercaseatoz,
                  onchanged: (value) {
                    context.read<GeneratedPasswordProvider>().lowercaseatoz =
                        value;
                  },
                  hinttext: 'Kucuk karakterler ( a - z )',
                  titletext: 'a-z',
                ),
                _buildSwitchOption(
                  value: context.watch<GeneratedPasswordProvider>().number,
                  onchanged: (value) {
                    context.read<GeneratedPasswordProvider>().number = value;
                  },
                  hinttext: 'Rakamlar ( 0 - 9 )',
                  titletext: '0-9',
                ),
                _buildSwitchOption(
                  value: context.watch<GeneratedPasswordProvider>().specialchar,
                  onchanged: (value) {
                    context.read<GeneratedPasswordProvider>().specialchar =
                        value;
                  },
                  hinttext: 'Ozel Karakterler ( !@#\$^&* )',
                  titletext: '!@#\$^&*',
                ),
                _buildCounterOption(
                  enabled: context.watch<GeneratedPasswordProvider>().number,
                  titletext: 'Minimum rakam',
                  hinttext: context
                      .watch<GeneratedPasswordProvider>()
                      .minimumnumbers
                      .floor()
                      .toString(),
                  onincreament: () {
                    context
                        .read<GeneratedPasswordProvider>()
                        .minimumnumberincrement();
                  },
                  ondecrement: () {
                    context
                        .read<GeneratedPasswordProvider>()
                        .minimumnumberdecrement();
                  },
                ),
                _buildCounterOption(
                  enabled:
                      context.watch<GeneratedPasswordProvider>().specialchar,
                  titletext: 'Mininum Ozel Karakter',
                  hinttext: context
                      .watch<GeneratedPasswordProvider>()
                      .minimumspecial
                      .floor()
                      .toString(),
                  onincreament: () {
                    context
                        .read<GeneratedPasswordProvider>()
                        .minimumnspecialincrement();
                  },
                  ondecrement: () {
                    context
                        .read<GeneratedPasswordProvider>()
                        .minimumspecialdecrement();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSiderOption({
    required String titletext,
    required String hinttext,
    required double value,
    required Function(double) onchanged,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(titletext),
        Row(
          children: [
            Text(hinttext),
            Slider(
              max: 20.0,
              min: 10,
              value: value,
              onChanged: onchanged,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSwitchOption({
    required String titletext,
    required String hinttext,
    required bool value,
    required Function(bool) onchanged,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(titletext),
        Row(
          children: [
            Text(hinttext),
            Switch(
              onChanged: onchanged,
              value: value,
            ),
          ],
        )
      ],
    );
  }

  Widget _buildCounterOption({
    required String titletext,
    required String hinttext,
    required VoidCallback onincreament,
    required VoidCallback ondecrement,
    required bool enabled,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(titletext),
        Row(
          children: [
            Text(hinttext),
            const SizedBox(
              width: 10,
            ),
            ElevatedButton(
              onPressed: enabled ? ondecrement : null,
              child: const Icon(
                Icons.remove,
              ),
            ),
            const SizedBox(
              width: 5,
            ),
            ElevatedButton(
              onPressed: enabled ? onincreament : null,
              child: const Icon(
                Icons.add,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
