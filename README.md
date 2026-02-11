# JLD — Java Libraries Downloader for CMake

JLD is a small, lightweight CMake module that allows you to **download and link Java libraries** (`.jar` files) directly in your CMake projects.
It supports both direct URLs and Maven-style coordinates (`GROUP + ARTIFACT + VERSION`).

---

## Features

- Download Java libraries from **Maven Central** or any custom repository.
- Supports **SHA256 verification** of downloads.
- Automatically creates **CMake imported targets** (`jld::<name>`).
- Cross-platform support for **classpath** (`:` on Unix, `;` on Windows).
- Easy to link jars to Java targets via `java_link_libraries()`.
- Includes optional documentation and can be packaged for installation.

---

## Requirements

- CMake >= 3.20
- Java JDK (for compilation of Java targets)

---

## Installation

Copy the module to your project or system:

```bash
cp cmake/JLD.cmake /path/to/your/project/cmake/
