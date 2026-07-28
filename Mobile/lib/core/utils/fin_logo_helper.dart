import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:idn_finlogos/idn_finlogos.dart';

class FinLogoHelper {
  static final Map<String, String> _customMapping = {
    'bca': 'bca',
    'bank central asia': 'bca',
    'bri': 'bri',
    'bank rakyat indonesia': 'bri',
    'bni': 'bni',
    'bank negara indonesia': 'bni',
    'mandiri': 'mandiri',
    'bank mandiri': 'mandiri',
    'dana': 'dana',
    'ovo': 'ovo',
    'gopay': 'gopay',
    'go-pay': 'gopay',
    'shopeepay': 'shopeepay',
    'shopee pay': 'shopeepay',
    'linkaja': 'linkaja',
    'link aja': 'linkaja',
    'bsi': 'bsi',
    'bank syariah indonesia': 'bsi',
    'btn': 'btn',
    'bank tabungan negara': 'btn',
    'cimb': 'cimb',
    'cimb niaga': 'cimb',
    'permata': 'permata',
    'bank permata': 'permata',
    'mega': 'mega',
    'bank mega': 'mega',
    'danamon': 'danamon',
    'bank danamon': 'danamon',
    'panin': 'panin',
    'bank panin': 'panin',
  };

  static LogoMeta? getLogoMeta(String providerName) {
    if (providerName.isEmpty) return null;

    final lowerName = providerName.toLowerCase().trim();
    String slug = lowerName;

    if (_customMapping.containsKey(lowerName)) {
      slug = _customMapping[lowerName]!;
    } else {
      // Fallback simple slugify (remove spaces, replace non-alphanumeric)
      slug = lowerName.replaceAll(RegExp(r'[^a-z0-9]'), '');
    }

    // Try exact get first
    LogoMeta? meta;
    try {
      meta = IdnFinLogos.get(slug);
    } catch (_) {}
    
    // If exact get fails, try search
    if (meta == null) {
      try {
        final searchResults = IdnFinLogos.search(slug);
        if (searchResults.isNotEmpty) {
          meta = searchResults.first;
        }
      } catch (_) {}
    }
    
    // If still fails and it wasn't mapped, try searching original name
    if (meta == null) {
      try {
        final searchResults = IdnFinLogos.search(lowerName);
        if (searchResults.isNotEmpty) {
          meta = searchResults.first;
        }
      } catch (_) {}
    }

    debugPrint('\n==================================================');
    debugPrint('🏦 FINLOGO DEBUG');
    debugPrint('Nama dari backend : "$providerName"');
    debugPrint('Slug digunakan    : "$slug"');
    debugPrint('Logo Ditemukan    : ${meta != null ? 'YA' : 'TIDAK'}');
    if (meta != null) {
      debugPrint('Asset Path        : ${meta.assetPath}');
    }
    debugPrint('==================================================\n');

    return meta;
  }

  static Widget getLogoWidget(String providerName, {double width = 40, double height = 24}) {
    final meta = getLogoMeta(providerName);
    if (meta != null) {
      return SvgPicture.asset(
        meta.assetPath,
        width: width,
        height: height,
        semanticsLabel: meta.name,
      );
    }
    return Icon(
      Icons.account_balance_rounded,
      size: height,
      color: Colors.grey.shade600,
    );
  }
}
