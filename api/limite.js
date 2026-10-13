// Limite de requisições por IP numa janela de tempo, para as rotas públicas que gravam ou consultam pedidos.
// shortcut: a contagem fica na memória deste processo, então vale para um servidor só; com vários servidores
// (ou reinícios frequentes), troque por um contador compartilhado (Redis, por exemplo).
function criarLimite({ janelaMs, max, relogio = Date.now }) {
  const registros = new Map(); // ip -> instantes das requisições dentro da janela

  const recentes = (ip, agora) => (registros.get(ip) ?? []).filter((t) => agora - t < janelaMs);

  // Sem isto o mapa cresceria com cada IP novo que aparece.
  const faxina = setInterval(() => {
    const agora = relogio();
    for (const ip of registros.keys()) {
      const lista = recentes(ip, agora);
      if (lista.length) registros.set(ip, lista);
      else registros.delete(ip);
    }
  }, janelaMs);
  faxina.unref();

  return (req, res, next) => {
    const agora = relogio();
    const lista = recentes(req.ip, agora);
    if (lista.length >= max) {
      res.set('Retry-After', String(Math.ceil((lista[0] + janelaMs - agora) / 1000)));
      return res.status(429).json({ erro: 'Muitas tentativas. Aguarde alguns minutos e tente de novo.' });
    }
    lista.push(agora);
    registros.set(req.ip, lista);
    next();
  };
}

module.exports = { criarLimite };
