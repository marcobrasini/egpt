import 'package:egpt/admin/widgets/dialog_form.dart';
import 'package:egpt/sources/source_training.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'widgets/member_page.dart';
import 'widgets/product_form.dart';
import 'widgets/product_tile.dart';
import 'widgets/delete_form.dart';
import '../models/member.dart';
import '../models/product.dart';
import 'source_admin.dart';

class AdminTraining extends StatefulWidget {
  const AdminTraining({super.key});

  @override
  State<AdminTraining> createState() => _AdminTrainingState();
}

class _AdminTrainingState extends State<AdminTraining> {
  late final TrainingSource training;
  bool _closing = false;

  void _checkMember() {
    if (!training.expired || _closing) return;
    _closing = true;
    WidgetsBinding.instance
      ..addPostFrameCallback((_) => close())
      ..scheduleFrame();
  }

  void close() {
    if (!mounted) return;
    final route = ModalRoute.of(context);
    if (route == null || !route.isActive) return;
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final name = training.member.name;

    navigator.popUntil((r) => r == route);
    navigator.removeRoute(route);
    messenger.showSnackBar(
      SnackBar(content: Text("Il membro '$name' è stato eliminato")),
    );
  }


  Future<Product> makeProduct() async {
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
              final product = await training.insertProduct(
                  Product.make(data: data..['member'] = training.member)
              );
              if (dialog.mounted) {
                if (product == null) {}
                Navigator.of(dialog).pop(product);
              }
            }
          },
        ),
      ]
    );
  }

  Future<Product?> editProduct(Product product) async {
    final productForm = GlobalKey<ProductFormState>();
    return await showFormDialog(
      context: context,
      title: "Abbonamento",
      content: ProductForm(product, key: productForm),
      actions: [
        FormAction("Cancella",
          onPressed: (dialog) async {
            final confirm = await showDeleteDialog(
              context: dialog,
              title: "Cancella abbonamento",
              message: ""
                "Stai eliminando l'abbonamento '${product.summary}' "
                "e tutte le sessioni di allenamento associate."
                "\nVuoi rimuovere l'abbonamento?",
              string: ""
                "${product.member.name}/${product.summary}".replaceAll(" ", ""),
            );
            if (confirm && context.mounted) {
              Navigator.of(dialog).pop(
                  await training.removeProduct(product)
              );
            }
          }
        ),
        FormAction("Modifica",
          onPressed: (dialog) async {
            if (productForm.currentState!.data case final data?) {
              if (dialog.mounted) {
                Navigator.of(dialog).pop(
                    await training.modifyProduct(product.set(data))
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
    training = context.read<TrainingSource>()..addListener(_checkMember);
    _checkMember();
  }

  @override
  void dispose() {
    training.removeListener(_checkMember);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<TrainingSource>();
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      endDrawer: Drawer(
        width: double.infinity,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: SingleChildScrollView(child: MemberPage(training.member)),
          ),
        ),
      ),
      body: RefreshIndicator.adaptive(
        onRefresh: () => training.admin.build(),
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              ),
              centerTitle: true,
              title: Text(training.member.name),
            ),
            SliverAppBar(
              pinned: true,
              automaticallyImplyActions: false,
              automaticallyImplyLeading: false,
              expandedHeight: 40.0,
              title: Stack(
                alignment: AlignmentDirectional.centerEnd,
                children: [
                  Row(
                    children: [
                      Text("Abbonamenti"),
                      SizedBox(width: 16.0),
                      Expanded(child: Divider()),
                    ],
                  ),
                  FloatingActionButton(
                    elevation: 0.0,
                    shape: const CircleBorder(),
                    child: const Icon(Icons.add),
                    onPressed: () => makeProduct(),
                  ),
                ],
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.all(16.0),
              sliver: (training.member.products.isEmpty)
                  ? SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Text(
                        "Nessun Abbonamento",
                        style: TextStyle(fontSize: 16.0, color: scheme.outline),
                      ),
                    ),
                  )
                  : SliverList.builder(
                    itemCount: training.member.products.length,
                    itemBuilder: (context, index) =>
                        ProductTile(
                          training.member.products[index],
                          () => editProduct(training.member.products[index]),
                        ),
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
