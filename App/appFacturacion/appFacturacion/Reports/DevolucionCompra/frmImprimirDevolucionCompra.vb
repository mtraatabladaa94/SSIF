﻿Imports Sadara.Models.V1.Database
Imports Sadara.Models.V1.POCO
Imports System.Data.Entity

Public Class frmImprimirDevolucionCompra
    Public iddevolucion As String
    Private Sub frmImprimirDevolucionCompra_Load(sender As Object, e As EventArgs) Handles MyBase.Load

        Log.Instance.RegisterActivity(
            If(Config.currentBusiness IsNot Nothing, Config.currentBusiness.IdEmpresa, Guid.Empty),
            "ReturnPurchasePrintReport",
            "Load",
            "Load ReturnPurchasePrintReport",
            userId:=If(Config.currentUser IsNot Nothing, Guid.Parse(Config.currentUser.IDUsuario), Nothing)
        )

        Try
            Using db As New CodeFirst
                Dim devolucion = db.ComprasDevoluciones.Where(Function(f) f.IDDEVOLUCION = Me.iddevolucion).FirstOrDefault
                If Not devolucion Is Nothing Then
                    If devolucion.ANULADO = "N" Then
                        Dim rpt As New rptImprimirDevolucionCompra
                        Config.CrystalTitle("DEVOLUCIÓN DE COMPRA", rpt)
                        rpt.SetDataSource((From dev In db.ComprasDevoluciones Join det In db.ComprasDevolucionesDetalles On dev.IDDEVOLUCION Equals det.IDDEVOLUCION Join ser In db.Series On dev.IDSERIE Equals ser.IDSERIE Join exi In db.Existencias On det.IDEXISTENCIA Equals exi.IDEXISTENCIA Join pro In db.Productos On exi.IDPRODUCTO Equals pro.IDPRODUCTO Join bod In db.Bodegas On exi.IDBODEGA Equals bod.IDBODEGA Where dev.IDDEVOLUCION = Me.iddevolucion Select bod, det, dev, exi, pro, ser, _N_EMPLEADO = dev.Empleado.N_TRABAJADOR, _EMPLEADO = dev.Empleado.NOMBRES & " " & dev.Empleado.APELLIDOS, _N_PROVEEDOR = If(Not dev.IDPROVEEDOR Is Nothing, dev.Proveedor.N_PROVEEDOR, ""), _PROVEEDOR = If(Not dev.IDPROVEEDOR Is Nothing, dev.Proveedor.NOMBRES & " " & dev.Proveedor.APELLIDOS, dev.PROVEEDORCONTADO) Select IDCOMPRA = dev.IDDEVOLUCION, BODEGA = bod.N_BODEGA & " | " & bod.DESCRIPCION, SERIE = ser.NOMBRE, dev.CONSECUTIVO, dev.N_DEVOLUCION, FECHA = dev.FECHADEVOLUCION, EMPLEADO = _N_EMPLEADO & " " & _EMPLEADO, PROVEEDOR = If(_N_PROVEEDOR = "", _N_PROVEEDOR & " " & _PROVEEDOR, _PROVEEDOR), CONDICION = If(dev.CREDITO, "Crédito", "Contado"), moneda = If(dev.MONEDA.Equals(Config.cordoba), "Córdoba", "Dólar"), dev.CONCEPTO, pro.IDALTERNO, pro.DESCRIPCION, CANTIDAD = det.CANTIDAD_DEVUELTA, PRECIO = det.PRECIOUNITARIO_C, DESCUENTO = det.DESCUENTO_DIN_TOTAL_C, det.SUBTOTAL_C, IVA = det.IVA_DIN_TOTAL_C, det.TOTAL_C, DESCUENTO_NETO = dev.DESCUENTO_DIN_C, SUBTOTAL_NETO = dev.SUBTOTAL_C, IVA_NETO = dev.IVA_DIN_C, TOTAL_NETO = dev.TOTAL_C, REIMPRESION = If(dev.REIMPRESION.Equals("S"), "COPIA", "ORIGINAL")).ToList())
                        CrystalReportViewer1.ReportSource = rpt
                        If devolucion.REIMPRESION <> "S" Then
                            devolucion.REIMPRESION = "S" : db.Entry(devolucion).State = EntityState.Modified : db.SaveChanges()
                        End If
                    Else
                        MessageBox.Show("Error, No se puede imprimir esta Devolución de Compra por que ha sido Anulada.")
                        Me.Close()
                    End If
                Else
                    MessageBox.Show("Error, No se encuentra esta Devolución de Compra.")
                    Me.Close()
                End If
            End Using
        Catch ex As Exception
            MessageBox.Show("Error, " & ex.Message)
            Me.Close()
        End Try
    End Sub

    Private Sub frmImprimirEntrada_FormClosing(sender As Object, e As FormClosingEventArgs) Handles MyBase.FormClosing
        Me.Dispose()
    End Sub

    Private Sub CrystalReportViewer1_ReportRefresh(source As Object, e As CrystalDecisions.Windows.Forms.ViewerEventArgs) Handles CrystalReportViewer1.ReportRefresh
        frmImprimirDevolucionCompra_Load(Nothing, Nothing)
    End Sub
End Class