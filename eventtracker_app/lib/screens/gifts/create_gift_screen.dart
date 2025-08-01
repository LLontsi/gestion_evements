import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/gift_model.dart';
import '../../providers/gift_provider.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_text_field.dart';

class CreateGiftScreen extends StatefulWidget {
  final String eventId;
  final GiftModel? gift; // Null pour un nouveau cadeau, non-null pour modification

  const CreateGiftScreen({
    super.key,
    required this.eventId,
    this.gift,
  });

  @override
  State<CreateGiftScreen> createState() => _CreateGiftScreenState();
}

class _CreateGiftScreenState extends State<CreateGiftScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;
  late TextEditingController _linkController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.gift?.name ?? '');
    _descriptionController = TextEditingController(text: widget.gift?.description ?? '');
    _priceController = TextEditingController(
        text: widget.gift?.price != null ? widget.gift!.price.toString() : '');
    _linkController = TextEditingController(text: widget.gift?.link ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _linkController.dispose();
    super.dispose();
  }

  Future<void> _saveGift() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final giftProvider = Provider.of<GiftProvider>(context, listen: false);

      final double price = _priceController.text.isEmpty
          ? 0
          : double.parse(_priceController.text.replaceAll(',', '.'));

      final giftToSave = GiftModel(
        id: widget.gift?.id ?? '',
        eventId: widget.eventId,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        price: price,
        link: _linkController.text.trim(),
        isReserved: widget.gift?.isReserved ?? false,
        reservedBy: widget.gift?.reservedBy ?? '',
      );

      if (widget.gift == null) {
        await giftProvider.createGift(giftToSave);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Cadeau ajouté avec succès')),
          );
        }
      } else {
        await giftProvider.updateGift(giftToSave);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Cadeau mis à jour avec succès')),
          );
        }
      }

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenTitle = widget.gift == null
        ? 'Ajouter un cadeau'
        : 'Modifier le cadeau';

    return Scaffold(
      appBar: CustomAppBar(
        title: screenTitle,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomTextField(
                controller: _nameController,
                label: 'Nom du cadeau',
                icon: Icons.card_giftcard,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un nom';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              CustomTextField(
                controller: _descriptionController,
                label: 'Description',
                icon: Icons.description,
                maxLines: 3,
              ),
              const SizedBox(height: 16),

              CustomTextField(
                controller: _priceController,
                label: 'Prix (€)',
                icon: Icons.euro,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    try {
                      double.parse(value.replaceAll(',', '.'));
                    } catch (e) {
                      return 'Veuillez entrer un prix valide';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              CustomTextField(
                controller: _linkController,
                label: 'Lien pour acheter',
                icon: Icons.link,
                keyboardType: TextInputType.url,
              ),
              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveGift,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : Text(widget.gift == null ? 'Ajouter' : 'Mettre à jour'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}