declare module 'dreamland/core' {
  export type FC<P = {}, S = {}> = any;
  export const css: any;
  export const use: any;
  export const createState: any;
  export const mapEach: any;
}

declare module 'dreamland/jsx-runtime' {
  export const jsx: any;
  export const jsxs: any;
  export const Fragment: any;
}

declare global {
  namespace JSX {
    interface IntrinsicElements {
      [elemName: string]: any;
    }
  }
}

export {};