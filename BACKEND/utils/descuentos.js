export const parsearDescuento = (valor) => {
    const texto = String(valor ?? '').trim();
    const coincidencia = /^(\d{1,3})\s*%?$/.exec(texto);
    if (!coincidencia) return null;

    const descuento = Number(coincidencia[1]);
    return Number.isInteger(descuento) && descuento >= 1 && descuento <= 100
        ? descuento
        : null;
};

export const calcularPrecioConDescuento = (precioOriginal, descuento) =>
    Math.round(precioOriginal * (100 - descuento) / 100);
