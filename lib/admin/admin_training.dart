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
  const AdminTraining(this.member, {super.key});

  final Member member;

  @override
  State<AdminTraining> createState() => _AdminTrainingState();
}

class _AdminTrainingState extends State<AdminTraining> {
  late final AdminSource admin;

  Future<void> _addProduct(BuildContext context) async {
    final admin = context.read<AdminSource>();
    final productForm = GlobalKey<ProductFormState>();
    await showDialog<Product>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Center(child: Text("Nuovo Abbonamento")),
        content: ProductForm(null, key: productForm),
        actionsAlignment: MainAxisAlignment.spaceBetween,
        actions: [
          TextButton(
            child: const Text("Annulla", style: TextStyle(fontSize: 16)),
            onPressed: () => Navigator.of(context).pop(null),
          ),
          TextButton(
            child: const Text("Aggiungi", style: TextStyle(fontSize: 16)),
            onPressed: () async {
              final navigator = Navigator.of(context);
              final data = productForm.currentState!.data;
              if (data != null && context.mounted) {
                data['member'] = widget.member;
                final product = await admin.insertProduct(
                  Product.make(data: data),
                );
                navigator.pop(product);
              }
            },
          ),
        ],
      ),
    );
  }

  Future<void> _setProduct(BuildContext context, Product product) async {
    final admin = context.read<AdminSource>();
    final productForm = GlobalKey<ProductFormState>();
    await showDialog<Product>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Center(child: Text("Abbonamento")),
        content: ProductForm(product, key: productForm),
        actionsAlignment: MainAxisAlignment.spaceBetween,
        actions: [
          TextButton(
            child: const Text("Annulla", style: TextStyle(fontSize: 16)),
            onPressed: () => Navigator.of(context).pop(null),
          ),
          TextButton(
            child: const Text("Modifica", style: TextStyle(fontSize: 16)),
            onPressed: () async {
              final navigator = Navigator.of(context);
              final data = productForm.currentState!.data;
              if (data != null && context.mounted) {
                await admin.modifyProduct(product.set(data));
                navigator.pop(product);
              }
            },
          ),
        ],
      ),
    );
  }

  Future<void> _delProduct(BuildContext context, Product product) async {
    final admin = context.read<AdminSource>();
    final form = GlobalKey<DeleteFormState>();
    await showDialog<Product>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Center(child: Text("Abbonamento")),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Stai eliminando l'abbonamento '${product.summary}' "
                  "e tutte le sessioni di allenamento associate."
                  "\nVuoi rimuovere l'abbonamento?",
            ),
            DeleteForm(
              "${widget.member.name}/${product.summary}".replaceAll(" ", ""),
              key: form,
            ),
          ],
        ),
        actionsAlignment: MainAxisAlignment.spaceBetween,
        actions: [
          TextButton(
            child: const Text("Annulla", style: TextStyle(fontSize: 16)),
            onPressed: () => Navigator.of(context).pop(null),
          ),
          TextButton(
            child: const Text("Elimina", style: TextStyle(fontSize: 16)),
            onPressed: () async {
              final navigator = Navigator.of(context);
              if (form.currentState?.confirm ?? false) {
                await admin.removeProduct(product);
                navigator.pop(product);
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    admin = context.read<AdminSource>();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final member = admin.register.memberSource[widget.member.id!];
    if (member == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) Navigator.of(context).maybePop();
      });
      return const SizedBox.shrink();
    }
    return Scaffold(
      endDrawer: Drawer(
        width: double.infinity,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: SingleChildScrollView(
                child: MemberPage(widget.member)
            ),
          ),
        ),
      ),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),
            centerTitle: true,
            title: Text(widget.member.name),
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
                  onPressed: () => _addProduct(context),
                ),
              ],
            ),
          ),
          Consumer<AdminSource>(
            builder: (context, source, _) {
              if (widget.member.products.isEmpty) {
                return SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Text(
                      "Nessun Abbonamento",
                      style: TextStyle(fontSize: 16.0, color: scheme.outline),
                    ),
                  ),
                );
              }
              return SliverPadding(
                padding: EdgeInsets.all(16.0),
                sliver: SliverList.builder(
                  itemCount: widget.member.products.length,
                  itemBuilder: (context, index) {
                    return ProductTile(
                      widget.member.products[index],
                          () => _setProduct(context, widget.member.products[index]),
                          () => _delProduct(context, widget.member.products[index]),
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
