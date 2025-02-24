import { ColumnMeta } from "@tanstack/table-core";

// Extend or augment the `.meta` interface
declare module "@tanstack/table-core" {
  interface ColumnMeta<TData, TValue> {
    label?: string;
  }
}
