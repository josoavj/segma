import 'package:flutter/material.dart';
import 'package:segma/models/models.dart';

class SegmentationControlPanel extends StatelessWidget {
  final TextEditingController promptController;
  final TextEditingController searchController;
  final SegmentationResult? segmentation;
  final bool isLoading;
  final VoidCallback onSegment;
  final ValueChanged<String> onSearchChanged;

  const SegmentationControlPanel({
    super.key,
    required this.promptController,
    required this.searchController,
    required this.segmentation,
    required this.isLoading,
    required this.onSegment,
    required this.onSearchChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 340,
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        border: Border(
          right: BorderSide(
            color: Colors.white.withValues(alpha: 0.05),
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          const _PanelHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const _SectionTitle('Prompt'),
                  const SizedBox(height: 10),
                  _PromptField(controller: promptController),
                  const SizedBox(height: 14),
                  _SegmentButton(
                    isLoading: isLoading,
                    onPressed: isLoading ? null : onSegment,
                  ),
                  const SizedBox(height: 24),
                  const _SoftDivider(),
                  const SizedBox(height: 24),
                  const _SectionTitle('Résultats'),
                  const SizedBox(height: 10),
                  _ResultsSection(
                    segmentation: segmentation,
                    searchController: searchController,
                    isLoading: isLoading,
                    onSearchChanged: onSearchChanged,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PanelHeader extends StatelessWidget {
  const _PanelHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withValues(alpha: 0.05),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF1F4A8A).withValues(alpha: 0.42),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.auto_awesome,
              color: Color(0xFF8FD1FF),
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            'Segmentation',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _PromptField extends StatelessWidget {
  final TextEditingController controller;

  const _PromptField({required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      minLines: 3,
      maxLines: 5,
      style: const TextStyle(color: Colors.white, fontSize: 13),
      decoration: _darkInputDecoration(
        hintText: 'Exemple: "person", "car", "où est la voiture ?"',
        prefixIcon: Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 0, 16),
          child: Icon(
            Icons.edit_note,
            color: Colors.white.withValues(alpha: 0.5),
            size: 20,
          ),
        ),
      ),
    );
  }
}

class _SegmentButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback? onPressed;

  const _SegmentButton({
    required this.isLoading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isLoading
              ? [
                  Colors.blue.withValues(alpha: 0.5),
                  Colors.cyan.withValues(alpha: 0.5),
                ]
              : [Colors.blue.shade600, Colors.blue.shade700],
        ),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isLoading)
                  const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(Colors.white),
                    ),
                  )
                else
                  const Icon(Icons.search, color: Colors.white, size: 20),
                const SizedBox(width: 10),
                const Text(
                  'Segmenter',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ResultsSection extends StatelessWidget {
  final SegmentationResult? segmentation;
  final TextEditingController searchController;
  final bool isLoading;
  final ValueChanged<String> onSearchChanged;

  const _ResultsSection({
    required this.segmentation,
    required this.searchController,
    required this.isLoading,
    required this.onSearchChanged,
  });

  @override
  Widget build(BuildContext context) {
    final result = segmentation;

    if (result != null && result.objects.isNotEmpty) {
      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: TextField(
              controller: searchController,
              style: const TextStyle(color: Colors.white, fontSize: 13),
              decoration: _darkInputDecoration(
                hintText: 'Filtrer les objets...',
                prefixIcon: Icon(
                  Icons.filter_list,
                  color: Colors.white.withValues(alpha: 0.5),
                  size: 18,
                ),
              ).copyWith(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
              ),
              onChanged: onSearchChanged,
            ),
          ),
          _ObjectList(
            objects: result.objects,
            query: searchController.text,
          ),
        ],
      );
    }

    if (result != null && result.objects.isEmpty) {
      return const _EmptyMessage('Aucun objet détecté');
    }

    if (!isLoading) {
      return const _EmptyMessage('Lancez une segmentation\npour voir les résultats');
    }

    return const SizedBox.shrink();
  }
}

class _ObjectList extends StatelessWidget {
  final List<SegmentedObject> objects;
  final String query;

  const _ObjectList({
    required this.objects,
    required this.query,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final normalizedQuery = query.toLowerCase();
    final visibleObjects = objects
        .where((object) => object.label.toLowerCase().contains(normalizedQuery))
        .toList();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      constraints: const BoxConstraints(maxHeight: 300),
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: visibleObjects.length,
        itemBuilder: (context, index) {
          final object = visibleObjects[index];

          return Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Colors.white.withValues(alpha: 0.05),
                  width: 0.5,
                ),
              ),
            ),
            child: ListTile(
              dense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
              leading: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.blue.withValues(alpha: 0.2),
                      Colors.cyan.withValues(alpha: 0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.blue.withValues(alpha: 0.3),
                    width: 0.5,
                  ),
                ),
                child: Center(
                  child: Text(
                    '${object.objectId}',
                    style: TextStyle(
                      color: scheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ),
              ),
              title: Text(
                object.label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              subtitle: Text(
                '${(object.confidence * 100).toStringAsFixed(0)}%',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 11,
                ),
              ),
              trailing: Icon(
                Icons.check_circle,
                color: scheme.tertiary.withValues(alpha: 0.7),
                size: 16,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _EmptyMessage extends StatelessWidget {
  final String message;

  const _EmptyMessage(this.message);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.4),
          fontSize: 12,
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }
}

class _SoftDivider extends StatelessWidget {
  const _SoftDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.transparent,
            Colors.white.withValues(alpha: 0.1),
            Colors.transparent,
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 18,
          decoration: BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}

InputDecoration _darkInputDecoration({
  required String hintText,
  required Widget prefixIcon,
}) {
  return InputDecoration(
    hintText: hintText,
    hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.4)),
    prefixIcon: prefixIcon,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
    ),
    focusedBorder: const OutlineInputBorder(
      borderSide: BorderSide(color: Colors.blue, width: 2),
    ),
    filled: true,
    fillColor: Colors.white.withValues(alpha: 0.03),
  );
}
