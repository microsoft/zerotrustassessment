import Balance from "react-wrap-balancer"

import { cn } from "@/lib/utils"

function PageHeader({
  className,
  children,
  ...props
}: React.HTMLAttributes<HTMLDivElement>) {
  return (
    <section
      className={cn(
        "pt-6 pb-4 flex items-center justify-between space-y-2",
        className
      )}
      {...props}
    >
      {children}
    </section>
  )
}

function PageHeaderHeading({
  className,
  ...props
}: React.HTMLAttributes<HTMLHeadingElement>) {
  return (
    <h1
      className={cn(
        "text-3xl font-semibold tracking-tight my-1",
        className
      )}
      {...props}
    />
  )
}

function PageHeaderDescription({
  className,
  ...props
}: React.HTMLAttributes<HTMLParagraphElement>) {
  return (
    <Balance
      className={cn(
        "max-w-[750px] text-lg text-muted-foreground sm:text-xl",
        className
      )}
      {...props}
    />
  )
}

export { PageHeader, PageHeaderHeading, PageHeaderDescription }