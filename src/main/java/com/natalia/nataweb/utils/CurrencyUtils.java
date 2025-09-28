package com.natalia.nataweb.utils;

import java.text.NumberFormat;
import java.util.Locale;

    public class CurrencyUtils {

        public static String format(double amount) {
            NumberFormat numberFormat = NumberFormat.getCurrencyInstance(Locale.of("es", "es"));
            return numberFormat.format(amount);
        }
    }

