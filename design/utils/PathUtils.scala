package utils

import java.nio.file.{Path, Paths}

object PathUtils {
  /**
   * Generates the absolute file system path for the target output directory
   * of a specific IP (Intellectual Property) module.
   *
   * This method dynamically constructs the path based on the calling class's
   * package name and a configurable middle path and target directory name.
   *
   * **Assumptions:**
   * - The current working directory of the JVM process (`System.getProperty("user.dir")`)
   * is the root of your project.
   * - The IP module's containing folder name in the file system directly corresponds
   * to the *last segment* of its Scala package name (e.g., if package is
   * `my.project.vga_sync_gen`, the IP folder name is assumed to be `vga_sync_gen`).
   * - The `middlePath` argument correctly represents the fixed hierarchy
   * between the project root and the IP module's folder.
   *
   * The resulting path will typically follow the structure:
   * `<project_root>/<middlePath>/<ipFolderName>/<targetName>`
   *
   * @param callingClass The `Class[_]` object of the module or object requesting the path.
   * This is typically obtained by `getClass` from within the calling
   * object or class. It is used to derive the `ipFolderName`
   * from its package name.
   * @param middlePath   (Optional) A string representing the fixed intermediate path
   * segments between the project's root directory and the
   * specific IP's folder. Defaults to "design/IPS".
   * Example: "design/IPS" if your structure is `project_root/design/IPS/vga_sync_gen/`.
   * @param targetName   (Optional) The name of the final directory where the
   * generated files (e.g., RTL) should be placed. Defaults to "rtl".
   * Example: "rtl" if you want the output in `.../vga_sync_gen/rtl/`.
   * @return An absolute `java.nio.file.Path` object representing the calculated
   * target output directory.
   */
  def getRtlOutputPath(
                        callingClass: Class[_],
                        middlePath : String = "design/IPS",
                        targetName : String = "rtl"
  ): Path = {
    val projectBasePath: Path = Paths.get(System.getProperty("user.dir")).toAbsolutePath

    // Get the package name of the calling class
    val packageName = callingClass.getPackage.getName

    // Extract the last segment of the package name to use as the IP folder name
    // This assumes your IP folder name directly corresponds to the last part of its package.
    // Example: for package "com.yourcompany.designs.vga_sync_gen", ipFolderName will be "vga_sync_gen".
    val ipFolderName: String = packageName.split("\\.").last

    // Construct the full path.
    // Note: The "design/IPS" prefix is hardcoded here, as it appears to be a fixed part of your project structure.
    val desiredRtlPath: Path = projectBasePath.resolve(middlePath).resolve(ipFolderName).resolve(targetName)

    desiredRtlPath
  }
}


