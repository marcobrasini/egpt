import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:egpt/models/models.dart';
import 'package:egpt/sources/sources.dart';
import 'package:egpt/widgets/forms.dart';
import 'widgets/personal_tile.dart';
import 'widgets/member_page.dart';
import 'source_admin.dart';


class AdminPersonal extends StatefulWidget {
  const AdminPersonal(this.memberId, {super.key});

  final String memberId;

  @override
  State<AdminPersonal> createState() => _AdminPersonalState();
}

class _AdminPersonalState extends State<AdminPersonal> {
  late final PersonalSource personal;
  bool _closing = false;

  void check() {
    if (personal.loading || personal.healthy) return;
    if (_closing) return; _closing = true;
    WidgetsBinding.instance
      ..addPostFrameCallback((_) => close())
      ..scheduleFrame();
  }

  void close() {
    if (mounted) {
      final route = ModalRoute.of(context);
      if (route?.isActive ?? false) {
        final navigator = Navigator.of(context);
        final messenger = ScaffoldMessenger.of(context);
        navigator.popUntil((r) => r == route!);
        navigator.removeRoute(route!);
        messenger.showSnackBar(
          SnackBar(content: Text(
              "Il membro '${personal.name}' è stato eliminato"
          )),
        );
      }
    }
  }

  Future<Product> makeProduct(BuildContext context) async {
    final productForm = GlobalKey<ProductFormState>();
    return await showFormDialog(
        context: context,
        title: "Nuovo Abbonamento",
        content: ProductForm(null, key: productForm),
        actions: [
          FormAction('Annulla'),
          FormAction('Aggiungi',
            onPressed: (dialog) async {
              if (productForm.currentState!.data case final data?) {
                final product = await personal.insertProduct(
                    Product.make(data: data..['memberId'] = personal.member.id)
                );
                if (dialog.mounted) Navigator.of(dialog).pop(product);
              }
            },
          ),
        ]
    );
  }

  Future<Product?> editProduct(BuildContext context, Product product) async {
    final productForm = GlobalKey<ProductFormState>();
    return await showFormDialog(
        context: context,
        title: "Abbonamento",
        content: ProductForm(product, key: productForm),
        actions: [
          FormAction("Cancella",
              color: Theme.of(context).colorScheme.error,
              onPressed: (dialog) async {
                final confirm = await showDeleteDialog(
                  context: dialog,
                  title: "Cancella abbonamento",
                  message: ""
                      "Stai eliminando l'abbonamento '${product.summary}' "
                      "e tutte le sessioni di allenamento associate."
                      "\nVuoi rimuovere l'abbonamento?",
                  string: ""
                      "${product.member.name}/${product.summary}".replaceAll(
                      " ", ""),
                );
                if (confirm && context.mounted) {
                  Navigator.of(dialog).pop(
                      await personal.removeProduct(product)
                  );
                }
              }
          ),
          FormAction("Modifica",
            onPressed: (dialog) async {
              if (productForm.currentState!.data case final data?) {
                if (dialog.mounted) {
                  Navigator.of(dialog).pop(
                      await personal.modifyProduct(product.set(data))
                  );
                }
              }
            },
          )
        ]
    );
  }

  @override
  void initState() {
    super.initState();
    personal = context.read<AdminSource>().personal;
    personal
      ..open(widget.memberId)
      ..addListener(check);
    check();
    unawaited(personal.build());
  }

  @override
  void dispose() {
    personal.removeListener(check);
    personal.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ChangeNotifierProvider<PersonalSource>.value(
      value: personal,
      child: Builder(
        builder: (context) {
          return Selector<PersonalSource, (Member, List<Product>)>(
            selector: (_, selector) => (selector.member, selector.products),
            builder: (context, data, _) {
              final (member, products) = data;
              return Scaffold(
                endDrawer: Drawer(
                  width: double.infinity,
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: SingleChildScrollView(
                        child: MemberPage(member),
                      ),
                    ),
                  ),
                ),
                body: RefreshIndicator.adaptive(
                  onRefresh: () async => await personal.source.build(),
                  child: CustomScrollView(
                    slivers: [
                      SliverAppBar(
                        leading: IconButton(
                          icon: const Icon(Icons.arrow_back),
                          onPressed: () => Navigator.pop(context),
                        ),
                        centerTitle: true,
                        title: Text(member.name),
                        actions: [
                          _MemberAvatarButton(member),
                          // const SizedBox(width: 12.0),
                        ],
                      ),
                      SliverPadding(
                        padding: const EdgeInsets.all(8.0),
                        sliver: SliverAppBar(
                          pinned: true,
                          automaticallyImplyActions: false,
                          automaticallyImplyLeading: false,
                          expandedHeight: 40.0,
                          title: Stack(
                            alignment: AlignmentDirectional.centerEnd,
                            children: [
                              const Row(
                                spacing: 16.0,
                                children: [
                                  Text("Abbonamenti"),
                                  Expanded(child: Divider()),
                                ],
                              ),
                              FloatingActionButton(
                                elevation: 0.0,
                                shape: const CircleBorder(),
                                child: const Icon(Icons.add),
                                onPressed: () => makeProduct(context),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SliverPadding(
                        padding: EdgeInsets.all(16.0),
                        sliver: (products.isEmpty)
                            ? SliverFillRemaining(
                              hasScrollBody: false,
                              child: Center(
                                child: Text("Nessun Abbonamento",
                                  style: TextStyle(
                                    fontSize: 16.0,
                                    color: scheme.outline,
                                  ),
                                ),
                              ),
                            )
                            : SliverList.builder(
                              itemCount: products.length,
                              itemBuilder: (context, index) => PersonalTile(
                                products[index].id!,
                                open: () => editProduct(context, products[index]),
                              ),
                            ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _MemberAvatarButton extends StatelessWidget {
  const _MemberAvatarButton(this.member);

  final Member member;

  static String initials(String name) => name
      .trim()
      .split(RegExp(r'\s+'))
      .where((part) => part.isNotEmpty)
      .take(2)
      .map((part) => part.characters.first.toUpperCase())
      .join();

  @override
  Widget build(BuildContext context) {
    final text = initials(member.name);
    return IconButton(
      padding: const EdgeInsets.only(right: 12.0),
      onPressed: () => Scaffold.of(context).openEndDrawer(),
      icon: CircleAvatar(
        radius: 24.0,
        backgroundColor: member.color,
        foregroundColor: Colors.white,
        child: text.isEmpty
            ? const Icon(Icons.person, size: 18.0)
            : Text(text,
          style: const TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
