/**
 * Cartões cinzas no lugar da grade enquanto o catálogo carrega (o RvSkeleton do app). O brilho pulsa só para quem não
 * pediu menos movimento no sistema.
 */
export default function EsqueletoGrade({ quantos = 8, className = "" }: { quantos?: number; className?: string }) {
  return (
    <div role="status" aria-label="Carregando a coleção" className={`grid grid-cols-2 gap-x-4 gap-y-10 md:grid-cols-3 lg:grid-cols-4 ${className}`}>
      {Array.from({ length: quantos }, (_, i) => (
        <div key={i} aria-hidden className="motion-safe:animate-pulse">
          <div className="aspect-[4/5] rounded bg-elevado" />
          <div className="mt-3.5 h-5 w-3/4 rounded-sm bg-elevado" />
          <div className="mt-2 h-4 w-1/3 rounded-sm bg-elevado" />
        </div>
      ))}
    </div>
  );
}
