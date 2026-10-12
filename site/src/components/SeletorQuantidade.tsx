import { Minus, Plus } from "lucide-react";

interface Props {
  quantidade: number;
  aoMudar: (q: number) => void;
  minimo?: number;
}

/** Menos, número, mais, dentro de um contorno só. */
export default function SeletorQuantidade({ quantidade, aoMudar, minimo = 1 }: Props) {
  return (
    <div className="inline-flex items-center rounded border border-linha">
      <button
        type="button"
        aria-label="Diminuir quantidade"
        disabled={quantidade <= minimo}
        onClick={() => aoMudar(quantidade - 1)}
        className="flex h-11 w-11 items-center justify-center transition hover:bg-white/10 disabled:opacity-40"
      >
        <Minus className="h-4 w-4" />
      </button>
      <span className="w-8 text-center font-semibold tabular-nums" aria-live="polite">
        {quantidade}
      </span>
      <button
        type="button"
        aria-label="Aumentar quantidade"
        onClick={() => aoMudar(quantidade + 1)}
        className="flex h-11 w-11 items-center justify-center transition hover:bg-white/10"
      >
        <Plus className="h-4 w-4" />
      </button>
    </div>
  );
}
