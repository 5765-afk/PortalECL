package pt.ecl.util;

import javax.crypto.SecretKeyFactory;
import javax.crypto.spec.PBEKeySpec;
import java.security.MessageDigest;
import java.security.SecureRandom;
import java.util.Base64;

/** Hash de palavras-passe com PBKDF2 (não guardar palavras-passe em texto simples). */
public final class Seguranca {
    private static final int ITERACOES = 210_000;
    private static final int TAMANHO = 256;
    private Seguranca() { }

    public static String gerarHash(String palavraPasse) {
        byte[] sal = new byte[16];
        new SecureRandom().nextBytes(sal);
        return "pbkdf2$" + ITERACOES + "$" + Base64.getEncoder().encodeToString(sal)
                + "$" + Base64.getEncoder().encodeToString(derivar(palavraPasse.toCharArray(), sal, ITERACOES));
    }

    public static boolean verificar(String palavraPasse, String hash) {
        try {
            String[] partes = hash.split("\\$");
            if (partes.length != 4 || !"pbkdf2".equals(partes[0])) return false;
            int iteracoes = Integer.parseInt(partes[1]);
            byte[] sal = Base64.getDecoder().decode(partes[2]);
            byte[] esperado = Base64.getDecoder().decode(partes[3]);
            return MessageDigest.isEqual(esperado, derivar(palavraPasse.toCharArray(), sal, iteracoes));
        } catch (RuntimeException e) { return false; }
    }

    private static byte[] derivar(char[] palavra, byte[] sal, int iteracoes) {
        try {
            PBEKeySpec spec = new PBEKeySpec(palavra, sal, iteracoes, TAMANHO);
            byte[] resultado = SecretKeyFactory.getInstance("PBKDF2WithHmacSHA256").generateSecret(spec).getEncoded();
            spec.clearPassword();
            return resultado;
        } catch (Exception e) { throw new IllegalStateException("Não foi possível proteger a palavra-passe.", e); }
    }
}
