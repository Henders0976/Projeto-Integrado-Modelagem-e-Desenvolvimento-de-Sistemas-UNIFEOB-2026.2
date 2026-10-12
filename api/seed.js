// Importa assets/catalogo.json para o banco (pode rodar de novo: atualiza, sem apagar estoque).
// ponytail: cor/tamanho que saírem do catálogo não são removidos do banco; apague à mão.
const fs = require('fs');
const path = require('path');
const db = require('./db');

// INSERT que devolve o id da linha, nova ou já existente.
const upsertId = async (con, sql, params, idCol) => {
  const [r] = await con.query(`${sql} ON DUPLICATE KEY UPDATE ${idCol} = LAST_INSERT_ID(${idCol})`, params);
  return r.insertId;
};

(async () => {
  const { pecas } = JSON.parse(
    fs.readFileSync(path.join(__dirname, '..', 'assets', 'catalogo.json'), 'utf8'));
  const con = await db.getConnection();
  try {
    await con.beginTransaction();

    // Tamanhos padrão primeiro, para a ordem P, M, G, GG, Único valer em todo produto.
    await con.query("INSERT IGNORE INTO tamanho (nome) VALUES ('P'), ('M'), ('G'), ('GG'), ('Único')");

    // Administrador dono do catálogo. A senha é só um marcador: ninguém entra com ela.
    const admin = await upsertId(con,
      "INSERT INTO administrador (nome, email, senha) VALUES ('Administradora RV Label', 'admin@rvlabel.com.br', 'sem-login')",
      [], 'id_admin');

    for (const p of pecas) {
      const acessorio = p.tipo === 'acessorio';
      const idCategoria = await upsertId(con,
        'INSERT INTO categoria (nome, id_admin) VALUES (?, ?)', [p.categoria, admin], 'id_categoria');

      const [r] = await con.query(
        `INSERT INTO produto (codigo, tipo, nome, descricao, preco, material, id_categoria, id_admin)
         VALUES (?, ?, ?, ?, ?, ?, ?, ?)
         ON DUPLICATE KEY UPDATE id_produto = LAST_INSERT_ID(id_produto), tipo=VALUES(tipo),
           nome=VALUES(nome), descricao=VALUES(descricao), preco=VALUES(preco),
           material=VALUES(material), id_categoria=VALUES(id_categoria)`,
        [p.id, acessorio ? 'acessorio' : 'peca', p.nome, p.descricao ?? '', p.preco ?? null,
         p.material ?? null, idCategoria, admin]);
      const idProduto = r.insertId;

      // Mesmos padrões do Produto.fromJson do app.
      const cores = p.cores?.length ? p.cores : [{ nome: 'Única' }];
      const tamanhos = acessorio ? ['Único'] : (p.tamanhos ?? ['P', 'M', 'G']);
      const frente = (p.fotos ?? [])[0] ?? '';

      const idsTamanho = [];
      for (const t of tamanhos) {
        idsTamanho.push(await upsertId(con, 'INSERT INTO tamanho (nome) VALUES (?)', [t], 'id_tamanho'));
      }
      for (const [i, c] of cores.entries()) {
        const idCor = await upsertId(con, 'INSERT INTO cor (nome) VALUES (?)', [c.nome], 'id_cor');
        await con.query(
          `INSERT INTO produto_cor (id_produto, id_cor, foto_frente, foto_costas, hue, tom, ordem)
           VALUES (?, ?, ?, ?, ?, ?, ?)
           ON DUPLICATE KEY UPDATE foto_frente=VALUES(foto_frente), foto_costas=VALUES(foto_costas),
             hue=VALUES(hue), tom=VALUES(tom), ordem=VALUES(ordem)`,
          [idProduto, idCor, frente, acessorio ? null : (p.fotoCostas ?? null), c.hue ?? null, c.tom ?? null, i]);
        for (const idTamanho of idsTamanho) {
          // Variação nova entra sem controle de estoque; a existente mantém a quantidade.
          await con.query(
            `INSERT INTO variacao (id_produto, id_cor, id_tamanho) VALUES (?, ?, ?)
             ON DUPLICATE KEY UPDATE id_produto = id_produto`,
            [idProduto, idCor, idTamanho]);
        }
      }
    }
    await con.commit();
    console.log(`${pecas.length} produtos importados.`);
  } catch (e) {
    await con.rollback();
    console.error(e);
    process.exitCode = 1;
  } finally {
    con.release();
    await db.end();
  }
})();
