"""CLI simples pra imprimir etiquetas em impressora TSPL via /dev/usb/lp0.

Cobre o caso "Fase 1": texto, QR code e código de barras Code128 usando os
comandos nativos TEXT/QRCODE/BARCODE do TSPL — sem conversão bitmap.
Fase 2 (PDF de e-commerce → bitmap → BITMAP command) vai ser um subcomando
novo quando precisarmos.
"""
import argparse
import shlex
import sys


DEFAULT_DEVICE = "/dev/usb/lp0"
DEFAULT_WIDTH_MM = 100
DEFAULT_HEIGHT_MM = 150
DEFAULT_GAP_MM = 2
DEFAULT_DENSITY = 8
DEFAULT_SPEED = 4

# 203 dpi (padrão dessas impressoras) = 8 dots/mm
DOTS_PER_MM = 8


def build_tspl(args):
    lines = [
        f"SIZE {args.width} mm, {args.height} mm",
        f"GAP {args.gap} mm, 0",
        "DIRECTION 1",
        f"DENSITY {args.density}",
        f"SPEED {args.speed}",
        "CLS",
    ]

    x = args.margin * DOTS_PER_MM
    y = args.margin * DOTS_PER_MM

    for text in args.text:
        escaped = text.replace('"', '\\"')
        lines.append(f'TEXT {x},{y},"{args.font}",0,{args.text_scale},{args.text_scale},"{escaped}"')
        y += 24 * args.text_scale + 8

    if args.barcode:
        y += 10
        escaped = args.barcode.replace('"', '\\"')
        lines.append(
            f'BARCODE {x},{y},"128",{args.barcode_height},1,0,'
            f'{args.barcode_narrow},{args.barcode_wide},"{escaped}"'
        )
        y += args.barcode_height + 30

    if args.qr:
        y += 10
        escaped = args.qr.replace('"', '\\"')
        lines.append(f'QRCODE {x},{y},{args.qr_ecc},{args.qr_cell},A,0,"{escaped}"')

    lines.append(f"PRINT {args.copies},1")
    return ("\r\n".join(lines) + "\r\n").encode("utf-8")


def main():
    parser = argparse.ArgumentParser(
        description="Imprime etiquetas TSPL (POS Label Printer 0416:5011)",
        formatter_class=argparse.ArgumentDefaultsHelpFormatter,
    )
    parser.add_argument("--text", action="append", default=[],
                        help="Linha de texto (repetir a flag pra várias linhas)")
    parser.add_argument("--barcode", help="Conteúdo do código de barras Code128")
    parser.add_argument("--qr", help="Conteúdo do QR code")

    parser.add_argument("--width", type=int, default=DEFAULT_WIDTH_MM, help="Largura (mm)")
    parser.add_argument("--height", type=int, default=DEFAULT_HEIGHT_MM, help="Altura (mm)")
    parser.add_argument("--gap", type=int, default=DEFAULT_GAP_MM, help="Gap entre etiquetas (mm)")
    parser.add_argument("--margin", type=int, default=4, help="Margem esquerda/topo (mm)")

    parser.add_argument("--density", type=int, default=DEFAULT_DENSITY,
                        help="Densidade de calor (0-15)")
    parser.add_argument("--speed", type=int, default=DEFAULT_SPEED,
                        help="Velocidade de impressão (1-5)")

    parser.add_argument("--font", default="3",
                        help="Fonte TSPL builtin (1-8; 3 é boa pra tudo)")
    parser.add_argument("--text-scale", type=int, default=1, help="Multiplicador de texto")

    parser.add_argument("--barcode-height", type=int, default=80, help="Altura barras (dots)")
    parser.add_argument("--barcode-narrow", type=int, default=2, help="Largura barra fina")
    parser.add_argument("--barcode-wide", type=int, default=2, help="Largura barra larga")

    parser.add_argument("--qr-cell", type=int, default=8, help="Tamanho da célula do QR")
    parser.add_argument("--qr-ecc", default="M", choices=["L", "M", "Q", "H"],
                        help="Nível de correção do QR")

    parser.add_argument("--copies", type=int, default=1)
    parser.add_argument("--device", default=DEFAULT_DEVICE,
                        help="Device da impressora (ou '-' pra stdout / preview)")

    args = parser.parse_args()

    if not (args.text or args.barcode or args.qr):
        parser.error("nenhum conteúdo — passa pelo menos --text, --barcode ou --qr")

    payload = build_tspl(args)

    if args.device == "-":
        sys.stdout.buffer.write(payload)
        return

    try:
        with open(args.device, "wb") as f:
            f.write(payload)
    except PermissionError:
        sys.stderr.write(
            f"erro: sem permissão em {args.device}. "
            f"confere se você tá no grupo 'lp' ({shlex.quote('groups')}) — "
            "se acabou de adicionar, relogue ou 'newgrp lp'\n"
        )
        sys.exit(1)
    except FileNotFoundError:
        sys.stderr.write(
            f"erro: {args.device} não existe. módulo usblp carregado? "
            "('lsmod | grep usblp' e 'sudo modprobe usblp')\n"
        )
        sys.exit(1)


if __name__ == "__main__":
    main()
