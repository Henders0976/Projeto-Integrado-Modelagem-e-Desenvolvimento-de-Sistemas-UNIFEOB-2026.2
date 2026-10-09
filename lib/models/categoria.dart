/// Categorias do menu do site.
enum Categoria {
  blusas('Blusas'),
  vestidos('Vestidos'),
  tops('Tops'),
  bodys('Bodys'),
  shorts('Shorts'),
  acessorios('Acessórios');

  const Categoria(this.rotulo);
  final String rotulo;
}
