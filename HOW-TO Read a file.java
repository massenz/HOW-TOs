// Copyright AlertAvert.com (c) 2014. All rights reserved

import java.io.*;

/**
 * Sample class that reads a file from either the classpath or the
 * filesystem.
 *
 * @author M. Massenzio (m.massenzio@gmail.com)
 */
public class SampleFileRead {

    /**
     * Reads a file from the Classpath and returns it as a single String
     *
     * @param name the full path (including leading '/') of the classpath resource
     * @return the contents of the resource
     * @throws IOException
     */
    public static String readFromClasspath(String name) throws IOException {
        InputStream is = SampleFileRead.class.getResourceAsStream(name);
        BufferedReader reader = new BufferedReader(new InputStreamReader(is));
        return readFromReader(reader);
    }

    /**
     * Reads from the filesystem the contents of the file whose full path is given
     *
     * @param path to the file in the filesystem
     * @return the contents of the file
     * @throws IOException
     */
    public static String readFromFilepath(String path) throws IOException {
        BufferedReader reader = new BufferedReader(new FileReader(path));
        return readFromReader(reader);
    }

    /**
     * Common method to read the file, one line after the other, and returning the contents as a single String
     *
     * @param reader
     * @return the contents of the file (more precisely, of the stream the {@code reader} points to)
     * @throws IOException
     */
    private static String readFromReader(BufferedReader reader) throws IOException {
        StringBuilder sb = new StringBuilder();
        String line;
        while ((line = reader.readLine()) != null) {
            sb.append(line)
                    .append('\n');
        }
        return sb.toString();
    }
}
