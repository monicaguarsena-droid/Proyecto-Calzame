import assert from 'node:assert/strict';
import { describe, it } from 'node:test';
import {
    calcularPrecioConDescuento,
    parsearDescuento
} from '../utils/descuentos.js';

describe('descuentos de ofertas', () => {
    it('acepta porcentajes válidos con o sin el signo %', () => {
        assert.equal(parsearDescuento('20'), 20);
        assert.equal(parsearDescuento('20%'), 20);
        assert.equal(parsearDescuento('100'), 100);
    });

    it('rechaza porcentajes fuera del rango o con formato inválido', () => {
        assert.equal(parsearDescuento('0'), null);
        assert.equal(parsearDescuento('101'), null);
        assert.equal(parsearDescuento('20.5'), null);
        assert.equal(parsearDescuento('20abc'), null);
    });

    it('calcula el precio descontado desde el precio original y redondea a pesos', () => {
        assert.equal(calcularPrecioConDescuento(100000, 20), 80000);
        assert.equal(calcularPrecioConDescuento(99999, 20), 79999);
        assert.equal(calcularPrecioConDescuento(50000, 100), 0);
    });
});
