import { obtenerPedidosEntregadosPorRango } from '../modelos/reportes.js';

const ZONA_HORARIA = 'America/Bogota';
const FORMATTER_BOGOTA = new Intl.DateTimeFormat('en-CA', {
    timeZone: ZONA_HORARIA,
    year: 'numeric',
    month: '2-digit',
    day: '2-digit',
    hour: '2-digit',
    hourCycle: 'h23'
});

const extraerPartes = (fecha) => Object.fromEntries(
    FORMATTER_BOGOTA.formatToParts(fecha)
        .filter((parte) => parte.type !== 'literal')
        .map(({ type, value }) => [type, value])
);

const fechaBogotaActual = () => {
    const { year, month, day } = extraerPartes(new Date());
    return `${year}-${month}-${day}`;
};

export const analizarFecha = (valor) => {
    if (typeof valor !== 'string' || !/^\d{4}-\d{2}-\d{2}$/.test(valor)) return null;

    const [year, month, day] = valor.split('-').map(Number);
    if (year < 1000 || month < 1 || month > 12 || day < 1) return null;
    const fecha = new Date(Date.UTC(year, month - 1, day));
    if (
        fecha.getUTCFullYear() !== year ||
        fecha.getUTCMonth() !== month - 1 ||
        fecha.getUTCDate() !== day
    ) return null;

    return { year, month, day };
};

const crearCubeta = (clave, etiqueta) => ({ periodo: clave, etiqueta, ventas: 0, pedidos: 0 });

export const crearPeriodo = (tipo, fecha) => {
    const { year, month, day } = fecha;
    let inicioLocal;
    let finLocal;
    let cubetas;

    if (tipo === 'diario') {
        inicioLocal = new Date(Date.UTC(year, month - 1, day));
        finLocal = new Date(Date.UTC(year, month - 1, day + 1));
        cubetas = Array.from({ length: 24 }, (_, hora) => {
            const clave = `${inicioLocal.toISOString().slice(0, 10)}T${String(hora).padStart(2, '0')}`;
            return crearCubeta(clave, `${String(hora).padStart(2, '0')}:00`);
        });
    } else if (tipo === 'mensual') {
        inicioLocal = new Date(Date.UTC(year, month - 1, 1));
        finLocal = new Date(Date.UTC(year, month, 1));
        const dias = new Date(Date.UTC(year, month, 0)).getUTCDate();
        cubetas = Array.from({ length: dias }, (_, indice) => {
            const fechaDia = new Date(Date.UTC(year, month - 1, indice + 1));
            const clave = fechaDia.toISOString().slice(0, 10);
            return crearCubeta(clave, String(indice + 1).padStart(2, '0'));
        });
    } else if (tipo === 'trimestral') {
        const primerMes = Math.floor((month - 1) / 3) * 3;
        inicioLocal = new Date(Date.UTC(year, primerMes, 1));
        finLocal = new Date(Date.UTC(year, primerMes + 3, 1));
        cubetas = Array.from({ length: 3 }, (_, indice) => {
            const fechaMes = new Date(Date.UTC(year, primerMes + indice, 1));
            const clave = fechaMes.toISOString().slice(0, 7);
            return crearCubeta(clave, clave);
        });
    } else {
        inicioLocal = new Date(Date.UTC(year, 0, 1));
        finLocal = new Date(Date.UTC(year + 1, 0, 1));
        cubetas = Array.from({ length: 12 }, (_, indice) => {
            const fechaMes = new Date(Date.UTC(year, indice, 1));
            const clave = fechaMes.toISOString().slice(0, 7);
            return crearCubeta(clave, clave);
        });
    }

    // Bogotá usa UTC-5; se convierte cada medianoche local a su instante UTC.
    const desde = new Date(inicioLocal.getTime() + 5 * 60 * 60 * 1000);
    const hasta = new Date(finLocal.getTime() + 5 * 60 * 60 * 1000);
    return { desde, hasta, cubetas };
};

export const claveCubeta = (fecha, tipo) => {
    const partes = extraerPartes(new Date(fecha));
    if (tipo === 'diario') return `${partes.year}-${partes.month}-${partes.day}T${partes.hour}`;
    if (tipo === 'mensual') return `${partes.year}-${partes.month}-${partes.day}`;
    return `${partes.year}-${partes.month}`;
};

export const getReporteVentas = async (req, res) => {
    const { periodo } = req.params;
    if (!['diario', 'mensual', 'trimestral', 'anual'].includes(periodo)) {
        return res.status(400).json({
            error: 'Periodo inválido. Usa diario, mensual, trimestral o anual.'
        });
    }

    const fecha = analizarFecha(req.query.fecha ?? fechaBogotaActual());
    if (!fecha) {
        return res.status(400).json({ error: 'La fecha debe tener formato válido YYYY-MM-DD.' });
    }

    try {
        const rango = crearPeriodo(periodo, fecha);
        const { data: pedidos, error } = await obtenerPedidosEntregadosPorRango(
            rango.desde.toISOString(),
            rango.hasta.toISOString()
        );
        if (error) {
            console.error('Error al consultar pedidos para el reporte de ventas:', error);
            return res.status(500).json({ error: 'No se pudo generar el reporte de ventas.' });
        }

        const cubetasPorClave = new Map(rango.cubetas.map((cubeta) => [cubeta.periodo, cubeta]));
        let totalCentavos = 0;
        let totalPedidos = 0;

        for (const pedido of pedidos ?? []) {
            const cubeta = cubetasPorClave.get(claveCubeta(pedido.created_at, periodo));
            const total = Number(pedido.Total);
            if (!cubeta || !Number.isFinite(total)) continue;
            const centavos = Math.round(total * 100);
            cubeta.ventas += centavos;
            cubeta.pedidos += 1;
            totalCentavos += centavos;
            totalPedidos += 1;
        }

        return res.status(200).json({
            periodo,
            zonaHoraria: ZONA_HORARIA,
            estadoIncluido: 'Entregado',
            moneda: 'COP',
            desde: rango.desde.toISOString(),
            hasta: rango.hasta.toISOString(),
            totalVentas: totalCentavos / 100,
            cantidadPedidos: totalPedidos,
            promedioPorPedido: totalPedidos ? totalCentavos / 100 / totalPedidos : 0,
            desglose: rango.cubetas.map((cubeta) => ({
                ...cubeta,
                ventas: cubeta.ventas / 100
            }))
        });
    } catch (error) {
        console.error('Error al generar el reporte de ventas:', error);
        return res.status(500).json({ error: 'No se pudo generar el reporte de ventas.' });
    }
};
